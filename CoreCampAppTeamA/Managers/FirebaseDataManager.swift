//
//  FirebaseDataManager.swift
//  CoreCampAppTeamA
//
//  Created by Volodymyr Ostapyshyn on 26.11.2020.
//
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Foundation
import Kingfisher

class FirebaseDataManager {
    // MARK: - Functions

    static func configure() {
        FirebaseApp.configure()
    }

    static func reference(to collectionReference: String) -> CollectionReference {
        return Firestore.firestore().collection(collectionReference)
    }

    static func create<T: DocumentSerializable>(value: T) {
        guard let id = value.dictionary["id"] else { return }
        print(id)

        reference(to: "\(T.self)s").document(id as! String)
            .setData(value.dictionary) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    debugPrint("Document added with ID: \(id)")
                }
            }
    }

    static func readWithSnapshotListiner<T: DocumentSerializable>(_ callback: @escaping (_ result: [T]) -> Void) {
        reference(to: "\(T.self)s").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                debugPrint(error?.localizedDescription ?? "Error Snapshot")
                return
            }
            var result = [T]()
            for document in snapshot.documents {
                if let model = T.create(document.data()) {
                    result.append(model as! T)
                }
            }
            callback(result)
        }
    }

    static func read<T: DocumentSerializable>(_ callback: @escaping (_ result: [T]) -> Void) {
        let db = Firestore.firestore()
        var result = [T]()
        db.collection("\(T.self)s").getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let model = T.create(document.data()) {
                        result.append(model as! T)
                    }
                }
                callback(result)
            }
        }
    }

    static func updatePrizes<T: DocumentSerializable>(value: T) {
        reference(to: "\(T.self)s").whereField("id", isEqualTo: value.dictionary["id"]!).getDocuments(completion: {
            querySnapshot, err in
            if err != nil {
                // Some error occured
            } else if querySnapshot!.documents.count != 1 {
                // Perhaps this is an error for you?
            } else {
                let document = querySnapshot!.documents.first
                document!.reference.updateData([
                    "quantity": value.dictionary["quantity"]!,
                ])
            }
        })
    }

    static func deletePrize<T: DocumentSerializable>(value: T) {
        reference(to: "\(T.self)s").whereField("id", isEqualTo: value.dictionary["id"]!).getDocuments(completion: {
            querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        })
    }

    static func update<T: DocumentSerializable>(value: T) {
        reference(to: "\(T.self)s").document(value.dictionary["id"] as! String).setData(value.dictionary)
    }

    static func delete<T: DocumentSerializable>(value: T) {
        reference(to: "\(T.self)s").document(value.dictionary["id"] as! String).delete()
    }

    static func download(imageUrl: String, _ callback: @escaping (_ image: UIImage) -> Void) {
        let ref = Storage.storage().reference(forURL: imageUrl)
        let megaByte = Int64(1 * 1024 * 1024)
        ref.getData(maxSize: megaByte) { data, _ in
            guard let imageData = data,
                  let image = UIImage(data: imageData) else { return }
            callback(image)
        }
    }

    static func deleteImageFromStorage(withDirectory: String, name: String) {
        let ref = Storage.storage().reference().child(withDirectory).child(name)

        ref.delete { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("File deleted successfully")
            }
        }
    }

    static func upload(photo: UIImage, toDirectory: String, withName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = Storage.storage().reference().child(toDirectory).child(withName)

        guard let imageData = photo.jpegData(compressionQuality: 0.4) else { return }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        ref.putData(imageData, metadata: metadata) { metadata, error in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            ref.downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                let urlString = url.absoluteString
                print("Download URL: \(urlString)")
                completion(.success(url))
            }
        }
    }

    static func grabImage(url: String, completion: @escaping (_ image: UIImage) -> Void) {
        guard let downloadURL = URL(string: url) else { return }

        let resource = ImageResource(downloadURL: downloadURL)
        KingfisherManager.shared.retrieveImage(with: resource) { result in
            switch result {
            case let .success(retrieveImageResult):
                let image = retrieveImageResult.image
                completion(image)
                let cacheType = retrieveImageResult.cacheType
                let source = retrieveImageResult.source
                let originalSource = retrieveImageResult.originalSource
                let message = """
                Image size:
                \(image.size)

                Cashe:
                \(cacheType)

                Source:
                \(source)

                Original source:
                \(originalSource)
                """
                print(message)
            case let .failure(err):
                print(err.localizedDescription)
            }
        }
    }
}
