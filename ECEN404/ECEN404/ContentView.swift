//
//  ContentView.swift
//  ECEN404
//
//  Created by Matthew Reyna on 11/15/23.
//

import SwiftUI

import AVKit

import WebKit //**************

import Auth0

import UserNotifications





//*********

struct WebView: UIViewRepresentable {

    let urlString: String



    func makeUIView(context: Context) -> WKWebView {

        return WKWebView()

    }



    func updateUIView(_ uiView: WKWebView, context: Context) {

        if let url = URL(string: urlString) {

            let request = URLRequest(url: url)

            uiView.load(request)

        }

    }

}

//*******

struct ContentView: View {

        //setting variables for auth0

    @State private var isAuthenticated = false

    @State var userProfile = Profile.empty

    

    //setting variables for video streaming

    @State private var selectedVideoIndex = 0

    @State private var showRecordings = false

    

    //streams video from AWS S3 bucket using domain name

    // https://www.youtube.com/watch?v=BPOJ3krxpVc

    let videos = [

            "http://10.10.131.156:5000/video_feed",

            "http://10.10.131.156:8080/video_feed",

            "http://10.10.131.170:2020/video_feed",

    ]

    //setting variable for date setting on overlay of app

    var dateFormatter: DateFormatter {

        let formatter = DateFormatter()

        formatter.dateFormat = "MMM dd, yyyy - h:mm:ss a"

        return formatter

    }

    

    //setting body for the app home view

    var body: some View {

              

      if isAuthenticated {

          //if login passes then the app view is this

          NavigationView {

              //stack is set vertically so objects are shown in order of code

              VStack {

                  //setting parameters of the video view on the screen

                  WebView(urlString: videos[selectedVideoIndex])

                      .frame(height: 450)

                      .overlay(

                        //setting the date overlay over the video view

                          HStack {

                              //sets text from variabe

                              Text(dateFormatter.string(from: Date()))

                                  .foregroundColor(.white)

                                  .padding()

                                  .background(Color.black.opacity(0.5))

                                  .cornerRadius(10)

                                  .padding(.leading)

                              Spacer()

                          },

                          alignment: .topLeading

                      )

                  //sets video picker under to allow user to choose from 3 video views

                  Picker(selection: $selectedVideoIndex, label: Text("Select a video")) {

                      Text("Door").tag(0)

                      Text("Room 1").tag(1)

                      Text("Room 2").tag(2)

                  }

                  .pickerStyle(SegmentedPickerStyle())

                  .padding()

                  

                  //button is set under the picker view to allow access to the past recordings page

                  NavigationLink(

                      destination: RecordingsView(),

                      isActive: $showRecordings,

                      label: {

                          Text("Previous Recordings")

                      })

                      .padding()

                  

                 //adds button to logout and go to logout page

                  Button("Log out") {

                      logout()

                    }

                    .buttonStyle(MyButtonStyle())

                  

                  Spacer()

              }

              //sets title at the top of the screen view

              .navigationTitle("Home Security System")

          

        }

          

    } else {

        //if not logged in then the app view is this

        VStack {

          

          Text("Welcome to your Security Cameras.")

            .modifier(TitleStyle())

          

            //givs login popup to Auth0 API

          Button("Log in") {

            login()

          }

          .buttonStyle(MyButtonStyle())

          

        }

        

      }


      

    }

    //Format for login screen title

struct TitleStyle: ViewModifier {

  let titleFontBold = Font.title.weight(.bold)

    let WordColor = Color(red: 0.6, green: 0, blue: 0.0)

  

  func body(content: Content) -> some View {

    content

      .font(titleFontBold)

      .foregroundColor(WordColor)

      .padding()

  }

}



    //Button format for login and logout

struct MyButtonStyle: ButtonStyle {

  let BubbleColor = Color(red: 0, green: 0, blue: 0.5)

  

    func makeBody(configuration: Configuration) -> some View {

        configuration.label

            .padding()

            .background(BubbleColor)

            .foregroundColor(.white)

            .clipShape(Capsule())

    }

  }

}









// setting notifications

func scheduleNotification() {

    let content = UNMutableNotificationContent()

    content.title = "Reminder"

    content.body = "Don't forget to check your security cameras."

    content.sound = .default

    

    // sets the time for the notification

    var dateComponents = DateComponents()

    dateComponents.hour = 9

    dateComponents.minute = 30

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

    

    // asks user to request notifications

    let request = UNNotificationRequest(identifier: "securityCameraReminder", content: content, trigger: trigger)



    // set the timer to the actual system

    let notificationCenter = UNUserNotificationCenter.current()

    notificationCenter.add(request) { (error) in

        if let error = error {

            print("Error scheduling notification: \(error.localizedDescription)")

        }

    }

}









extension ContentView {

    //sets the login function to access auth0 API to allow user to login

      //sets the login function to access auth0 API to allow user to login

  func login() {

    Auth0

      .webAuth()

      .start { result in

        switch result {

          case .failure(let error):

            print("Failed with: \(error)")



          case .success(let credentials):

            self.isAuthenticated = true

            self.userProfile = Profile.from(credentials.idToken)

            print("Credentials: \(credentials)")

            print("ID token: \(credentials.idToken)")

        }

      }

  }

  //lets user logout of the app using auth0

  func logout() {

    Auth0

      .webAuth()

      .clearSession { result in

        switch result {

          case .success:

            self.isAuthenticated = false

            self.userProfile = Profile.empty
          case .failure(let error):

            print("Failed with: \(error)")

        }

      }

  }

  

}

// allows the view of the previous recordings view say that there are currently not recordings to demonstrate the page works. The connection to S3 bucket will be here

struct RecordingsView: View {

    var body: some View {

        Text("No Previous Recordings")

            .navigationTitle("Recordings")

    }

}

// brings the file to the app to show

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {

        ContentView()

    }

    

    struct RecordingsView: View {

        var body: some View {

            Text("No Previous Recordings")

                .navigationTitle("Recordings")

        }

    }

    // brings the file to the app to show

    struct ContentView_Previews: PreviewProvider {

        static var previews: some View {

            ContentView()

        }

    }

    

    

}
