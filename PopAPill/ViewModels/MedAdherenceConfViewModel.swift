//
//  MedAdherenceConfViewModel.swift
//  PopAPill
//
//  Created by stephanie 04/10/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MedAdherenceConfViewModel: ObservableObject{

    @Published var confirmationDate = Date ()
    @Published var confirmationSuccess = false
    //tracks user confirmation
    @Published var isConfirmed = false
    @Published var errorM = ""

    init(){}

    func confirmMedication(){
        errorM = ""
        confirmationSuccess = false

        guard validate() else{
            return
        }

        guard let userID = Auth.auth().currentUser?.uid else{
            errorM = "User not logged in"
            return
        }

        let db = Firestore.firestore()
        let adherenceRef = db.collection("users").document(userID).collection("adherence")

        //class to convert date from object to string
        let dateFormatter = DateFormatter()
        //build of the date
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: confirmationDate)
        //document ID for history of confirmations
        let documentID = "medication_\(dateString)"

        //storing confirmation data to Firestore
        let data: [String: Any] = [
            "isConfirmed" : isConfirmed,
            "confirmedAt": Timestamp(date: confirmationDate),
            "dateString": dateString
        ]

        //storing data to Firestore
        adherenceRef.document(documentID).setData(data){
            [weak self] error in DispatchQueue.main.async{
                if let error = error{
                    self?.errorM = "Failed to confirm medication: \(error.localizedDescription)"
                }
                else{
                    self?.confirmationSuccess = true
                }
            }
        }
    }


}