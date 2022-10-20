//
//  ContentView.swift
//  CoreDataToCSVDemo
//
//  Created by Don Mag on 10/20/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.todaysDate, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
						let d = itemFormatter.string(from: item.todaysDate!) // (item.todaysDate!, formatter: itemFormatter)
						let h = String(item.hoursSlept)
						Text("Date: " + d + "\nHours " + h)
							.font(.largeTitle)
							.multilineTextAlignment(.center)
                    } label: {
						let d = itemFormatter.string(from: item.todaysDate!) // (item.todaysDate!, formatter: itemFormatter)
						let h = String(item.hoursSlept)
						Text("Date: " + d + " Hours " + h)
                    }
                }
                .onDelete(perform: deleteItems)
            }
			.toolbar {
				ToolbarItemGroup(placement: .navigationBarTrailing) {
					Button {
						addItem()
					} label: {
						Image(systemName: "plus.circle")
					}
					Button {
						print("tapped")
						exportCSV(withItems: items, toFileNamed: "SleepItems")
					} label: {
						Image(systemName: "square.and.arrow.down")
					}
				}
			}
        }
    }

	private func exportCSV(withItems arrayOfItems:FetchedResults<Item>, toFileNamed fName: String) {
		print("Exporting...")
		print()
		
		// header line for csv file
		var csvString = "Date, HoursSlept\n"
		
		// loop through items, appending a new
		//	csv line for each item
		arrayOfItems.forEach { item in
			if let td = item.todaysDate {
				let sDate = String(describing: td)
				let sHours = String(describing: item.hoursSlept)
				let csvLine = "\(sDate), \(sHours)\n"
				csvString.append(csvLine)
			}
		}
		
		// for debugging
		print("CSV String:")
		print()
		print(csvString)
		print()

		let fileManager = FileManager.default
		let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
		let path = directory.appendingPathComponent(fName).appendingPathExtension("csv")
		if(!fileManager.fileExists(atPath:path.path)){
			fileManager.createFile(atPath: path.path, contents: nil, attributes: nil)
		}
		do {
			try csvString.write(to: path, atomically: true, encoding: .utf8)
			print("CSV data saved to:", path)
		} catch let error {
			print("Error creating CSV export file \(error.localizedDescription)")
		}

	}

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.todaysDate = Date()
			newItem.hoursSlept = Int16(Int.random(in: 4...12))

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
