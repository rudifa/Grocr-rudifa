//
//  LoginManager.swift
//  Grocr
//
//  Created by Rudolf Farkas on 08.09.18.
//  Copyright © 2018 com.rudifa. All rights reserved.
//

import Firebase

extension Thread {
    class func getCurrent() -> String {
//        return ("\r⚡️: \(Thread.current)\r" + "🏭: \(OperationQueue.current?.underlyingQueue?.label ?? "None")\r")
        return ("⚡️: \(Thread.current)")
    }
}

class LoginManager: NSObject {
    static let shared = LoginManager()

    private override init() {
        super.init()
    }

    // this works for the UITest, however we don't know here whether onlineRef.removeValue() succeeded
    func userLogout() {
        print("--- userLogout enter", Date().HHmmssSSS, Thread.getCurrent())
        if let user = Auth.auth().currentUser {
            print("user.email=", user.email as Any, Thread.getCurrent())
            let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")

            print("--- before onlineRef.removeValue", Date().HHmmssSSS, Thread.getCurrent())
            onlineRef.removeValue()

            for i in 0 ..< 5 {
                if Auth.auth().currentUser != nil {
                    print("--- there was a current user", i, Date().HHmmssSSS, Thread.getCurrent())
                    do {
                        try Auth.auth().signOut()
                        print("Auth sign out succeeded", Date().HHmmssSSS, Thread.getCurrent())
                    } catch let error {
                        print("Auth sign out failed: \(error)")
                    }
                    sleep(1)
                } else {
                    break
                }
            }
        } else {
            print("--- No current user", Thread.getCurrent())
        }
        print("--- userLogout exit", Date().HHmmssSSS, Thread.getCurrent())
    }

    // no way yet to force the callback to execute before timeout expired
    // looks like onlineRef.removeValue dispatches the callback onto the main thread
    // so we can't override it short of finding it in firebase sdk the code and modifying
    func userLogout9() {
        print("--- userLogout enter", Date().HHmmssSSS, Thread.getCurrent())
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        DispatchQueue(label: "my dispatch queue", qos: .userInitiated, attributes: .concurrent).async {
            if let user = Auth.auth().currentUser {
                print("user.email=", user.email as Any, Thread.getCurrent())
                let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")

                print("--- before onlineRef.removeValue", Date().HHmmssSSS, Thread.getCurrent())
                onlineRef.removeValue { error, _ in
                    print("--- in callback 1", Date().HHmmssSSS, Thread.getCurrent())
                    DispatchQueue(label: "my 2nd dispatch queue", qos: .userInitiated, attributes: .concurrent).async {
                        print("--- in callback 2", Date().HHmmssSSS, Thread.getCurrent())
                        if let error = error {
                            print("Removing online failed: \(error)")
                            dispatchGroup.leave()
                        } else {
                            do {
                                try Auth.auth().signOut()
                                print("Auth sign out succeeded", Date().HHmmssSSS, Thread.getCurrent())
                                dispatchGroup.leave()
                            } catch let error {
                                print("Auth sign out failed: \(error)")
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
                print("--- there was a current user", Date().HHmmssSSS, Thread.getCurrent())
            } else {
                print("--- No current user", Thread.getCurrent())
            }
        }
        let result = dispatchGroup.wait(timeout: .now() + 5)
        print("--- result", result, Date().HHmmssSSS)
        print("--- userLogout exit", Date().HHmmssSSS, Thread.getCurrent())
    }

    // here removeValue and its callback run on different background threads, but still after the timeout
    func userLogout8() {
        print("--- userLogout enter", Date().HHmmssSSS, Thread.getCurrent())
        if let user = Auth.auth().currentUser {
            print("user.email=", user.email as Any, Thread.getCurrent())
            let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            dispatchGroup.enter()

            DispatchQueue(label: "my dispatch queue", attributes: .concurrent).async {
                print("--- before onlineRef.removeValue", Date().HHmmssSSS, Thread.getCurrent())
                onlineRef.removeValue { error, _ in
                    DispatchQueue(label: "my dispatch queue", attributes: .concurrent).async {
                        print("--- in callback", Date().HHmmssSSS, Thread.getCurrent())
                        if let error = error {
                            print("Removing online failed: \(error)")
                            dispatchGroup.leave()
                        } else {
                            do {
                                try Auth.auth().signOut()
                                print("Auth sign out succeeded", Date().HHmmssSSS, Thread.getCurrent())
                                dispatchGroup.leave()
                            } catch let error {
                                print("Auth sign out failed: \(error)")
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
            }
            dispatchGroup.leave()

            let result = dispatchGroup.wait(timeout: .now() + 5)
            print("--- result", result, Date().HHmmssSSS)
            print("--- there was a current user", Date().HHmmssSSS, Thread.getCurrent())
        } else {
            print("--- No current user", Thread.getCurrent())
        }
        print("--- userLogout exit", Date().HHmmssSSS, Thread.getCurrent())
    }

    // looks like removeValue runs on the main thread, but after the userLogout()
    // send it to another queue?
    func userLogout7() {
        if let user = Auth.auth().currentUser {
            print("user.email=", user.email as Any, Thread.getCurrent())
            let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
//            let dispatchGroup = DispatchGroup()
//            dispatchGroup.enter()
            onlineRef.removeValue { error, _ in
                if let error = error {
                    print("Removing online failed: \(error)")
//                    dispatchGroup.leave()
                } else {
                    do {
                        try Auth.auth().signOut()
                        print("Auth sign out succeeded", Date().HHmmssSSS, Thread.getCurrent())
//                        dispatchGroup.leave()
                    } catch let error {
                        print("Auth sign out failed: \(error)")
//                        dispatchGroup.leave()
                    }
                }
            }
//            let result = dispatchGroup.wait(timeout: .now() + 10)
//            print("--- result", result)
            print("--- there was a current user", Date().HHmmssSSS, Thread.getCurrent())
        } else {
            print("--- No current user", Thread.getCurrent())
        }
    }

    // this is based on the app's logout; I can't get it work
    // Auth.auth().signOut() succeeds, but apparently only after the wait() expired
    func userLogout6() {
        if let user = Auth.auth().currentUser {
            print("user.email=", user.email as Any)
            let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            onlineRef.removeValue { error, _ in
                if let error = error {
                    print("Removing online failed: \(error)")
                    dispatchGroup.leave()
                } else {
                    do {
                        try Auth.auth().signOut()
                        print("Auth sign out succeeded")
                        dispatchGroup.leave()
                    } catch let error {
                        print("Auth sign out failed: \(error)")
                        dispatchGroup.leave()
                    }
                }
            }
            let result = dispatchGroup.wait(timeout: .now() + 10)
            print("--- result", result)
        } else {
            print("--- No current user")
        }
    }

    // this makes the logout effective, but Remove online fails
    func userLogout5() {
        guard let user = Auth.auth().currentUser else {
            print("--- userLogout:", "No current user")
            return
        }
        let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")

        do {
            try Auth.auth().signOut()
            print("--- userLogout:", "Auth sign out succeeded", Date().HHmmssSSS)
            //                self.dismiss(animated: true, completion: nil)
            //                    dispatchGroup.leave()
            onlineRef.removeValue { error, _ in
                if let error = error {
                    print("--- userLogout:", "Removing online failed: \(error)")
                    //                dispatchGroup.leave()
                } else {
                    print("--- userLogout:", "Removing online succeeded")
                }
            }
        } catch let error {
            print("--- userLogout:", "Auth sign out failed: \(error)")
            //                    dispatchGroup.leave()
        }

        print("--- before sleep", Date().HHmmssSSS)
        sleep(5)
        print("--- after sleep", Date().HHmmssSSS)
    }

    func userLogout2() {
        guard let user = Auth.auth().currentUser else {
            print("--- userLogout:", "No current user")
            return
        }
        let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
        //        let dispatchGroup = DispatchGroup()
        //        dispatchGroup.enter()
        onlineRef.removeValue { error, _ in
            if let error = error {
                print("--- userLogout:", "Removing online failed: \(error)")
                //                dispatchGroup.leave()
            } else {
                do {
                    try Auth.auth().signOut()
                    print("--- userLogout:", "Auth sign out succeeded", Date().HHmmssSSS)
                    //                self.dismiss(animated: true, completion: nil)
                    //                    dispatchGroup.leave()
                } catch let error {
                    print("--- userLogout:", "Auth sign out failed: \(error)")
                    //                    dispatchGroup.leave()
                }
            }
            //            print("--- userLogout:", "dispatchGroup.leave()", Date().HHmmssSSS)
            //            dispatchGroup.leave()
        }
        //        print("--- wait...", Date().HHmmssSSS)
        //        let result = dispatchGroup.wait(timeout: .now() + 5)
        //        print("--- result", result, Date().HHmmssSSS)
        print("--- before sleep", Date().HHmmssSSS)
        sleep(5)
        print("--- after sleep", Date().HHmmssSSS)
    }

    func userLogout00() {
        do {
            let currentUser = Auth.auth().currentUser
            try Auth.auth().signOut()
            print("Auth sign out succeeded")

            if let user = currentUser {
//                print("user.email=", user.email as Any)
                let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
                onlineRef.removeValue { error, _ in
                    if let error = error {
                        print("Removing online failed: \(error)")
                        return
                    }
                }
            } else {
                print("--- No current user")
            }

        } catch let error {
            print("Auth sign out failed: \(error)")
        }
    }
}
