//
//  QuotesView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-09.
//

import SwiftUI
import WidgetKit
import UserNotifications
import UIKit
import Foundation

@available(iOS 16.0, *)
struct QuotesView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: QuotesViewModel

    @AppStorage("quoteFrequencyIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteFrequencyIndex: Int = 3
    
    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteCategory: QuoteCategory = .all
    
    init () {
        viewModel = QuotesViewModel(localQuotesService: LocalQuotesService(), apiService: APIService(), quoteFrequencyIndex: quoteFrequencyIndex, quoteCategory: quoteCategory)
    }
    
    var body: some View {
        NavigationStack{
            VStack {
                HeaderView()
                VStack{
                    Spacer()
                    quoteCategoryPicker
                    Spacer()
                    timeIntervalPicker
                    Spacer()
                    notificationSection
                    Spacer()
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        }
    }
}

@available(iOS 16.0, *)
struct QuotesView_Previews: PreviewProvider {
    static var previews: some View {
        QuotesView()
    }
}

@available(iOS 16.0, *)
extension QuotesView {
    public func getFormattedNotificationTime () -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"  // Use "h:mm a" for 12-hour format with AM/PM
        return dateFormatter.string(from: viewModel.getNotificationTime())
    }
    
    private var notificationSection: some View {
        Section {
            if viewModel.isTimePickerExpanded {
                Button(action: {
                    viewModel.isTimePickerExpanded.toggle()
                }) {
                    Text("Close")
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                        )
                }
                .padding()
                .sheet(isPresented: $viewModel.isTimePickerExpanded) {
                    notificationTimePicker
                }
            } else {
                Button(action: {
                    viewModel.scheduleNotificationsAction()
                }) {
                    HStack {
                        Text("Schedule Notifications")
                            .font(.headline)
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
                        Image(systemName: "calendar.badge.clock")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                    )
                }
                .padding()
            }
        }
    }
    
    private var notiTimePickerColor: some View {
        Group{
            if (colorScheme == .light) {
                Group {
                    DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .black)
                        .padding()
                        .scaleEffect(1.25)
                }
                .colorInvert()
                .colorMultiply(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
            } else {
                Group {
                    DatePicker("", selection: $viewModel.notificationTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .black)
                        .padding()
                        .scaleEffect(1.25)
                }
                // here we didn't do .colorInvert(), since we're on dark mode already
                .colorMultiply(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
            }
        }
    }
    
    private var notificationTimePicker: some View {
        VStack {
            Spacer()
            
            VStack {
                Text("Daily Notification Scheduling")
                    .font(.title)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .black)
                    .multilineTextAlignment(.center)
                Spacer()
                
                Text("\(viewModel.notificationScheduledTimeMessage)\(getFormattedNotificationTime)")
                    .font(.title2)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                    .padding()
                    .frame(alignment: .center)
                    .multilineTextAlignment(.center)

                notiTimePickerColor
                Spacer()
            }
            .onAppear() {
                viewModel.fetchNotificationScheduledTimeInfo()
            }
            .padding()
            Spacer()
            Button(action: {
                viewModel.handleNotificationScheduleAction()
            }) {
                Text("Done")
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                    )
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .frame(minWidth: 200, maxWidth: .infinity)
        .background(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear)
        .cornerRadius(8)
        .shadow(radius: 5)
    }
    private var timeIntervalPicker: some View {
        HStack {
            Text("Reload Widget:")
                .font(.headline)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                .padding(.horizontal, 5)
            
            HStack {
                Picker("", selection: $viewModel.quoteFrequencyIndex) {
                    ForEach(0..<viewModel.frequencyOptions.count, id: \.self) { index in
                        var frequencyText: String
                        switch viewModel.frequencyOptions[index]{
                            case "1 day": frequencyText = "day"
                            case "1 week": frequencyText = "week"
                            default: frequencyText = "\(viewModel.frequencyOptions[index])"
                        }
                        Text("Every \(frequencyText)")
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                .onReceive([self.quoteFrequencyIndex].publisher.first()) { _ in
                    WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                    WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? .clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                )
        )
    }
    private var quoteCategoryPicker: some View {
        HStack {
            Text("Quote Category:")
                .font(.headline)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
            Picker("", selection: $viewModel.quoteCategory) {
                if counts.isEmpty {
                    Text("Loading...")
                } else {
                    ForEach(QuoteCategory.allCases, id: \.self) { category in
                        if let categoryCount: Int = viewModel.counts[category.rawValue] {
                            let displayNameWithCount: String = "\(category.displayName) (\(categoryCount))"
                            Text(displayNameWithCount)
                                .font(.headline)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                        }
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
            .onAppear {
                viewModel.getCategoryCounts { fetchedCounts in
                    counts = fetchedCounts
                }
            }
            .onTapGesture {
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
            }
            
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? .clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 2)
                )
        )
    }
}
