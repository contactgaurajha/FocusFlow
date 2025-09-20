import SwiftUI

struct ContentView: View {
    @State private var newTask = ""
    @State private var tasks: [String] = []

    var body: some View {
        NavigationStack {
            VStack { Text("Welcome To FocusFlow!") .font(.system(size: 28).bold()) .padding(.top, 40)
            }
                HStack {
                    TextField("Enter a new reminder...", text: $newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity)

                    NavigationLink(destination: SwiftUIView()) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                .padding()

                List {
                    ForEach(tasks, id: \.self) { task in
                        Text(task)
                    }
                    .onDelete { indexSet in
                        tasks.remove(atOffsets: indexSet)
                    }
                }

                Spacer()
            }
            .navigationTitle("FocusFlow")
        }
    }


struct NewPageView: View {
    var body: some View {
        Text("This is the new page!")
            .font(.largeTitle)
            .bold()
    }
}

#Preview {
    ContentView()
}
