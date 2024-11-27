//
//  FCollectionReference.swift
//  LetsChat
//
//  Created by K Praveen Kumar on 15/11/24.
//

import Foundation
import FirebaseFirestoreInternal

enum FCollectionReference: String {
    case User
    case Recent
}

func firebaseRreference(_ collectionReference: FCollectionReference) -> CollectionReference  {
    return Firestore.firestore().collection(collectionReference.rawValue)
}

enum FirestoreCollectionReference: String {
    case User
}
