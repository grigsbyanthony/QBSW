import SwiftUI

struct ContentView: View {
    @ObservedObject var torrentData = TorrentData()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Name").bold().frame(maxWidth: .infinity, alignment: .leading)
                Divider().frame(height: 25)
                Text("Progress").bold().frame(width: 100, alignment: .center)
                Divider().frame(height: 25)
                Text("State").bold().frame(width: 80, alignment: .center)
                Divider().frame(height: 25)
                Text("Download Speed").bold().frame(width: 100, alignment: .center)
            }
            .padding(.horizontal)

            Divider()
            ScrollView {
                VStack(spacing: 0) {
                    if torrentData.torrents.isEmpty {
                        // If no data, show a placeholder message
                        Text("No torrents to display.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        // Loop through torrents and display them
                        ForEach(torrentData.torrents) { torrent in
                            HStack {
                                Text(torrent.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .truncationMode(.tail)

                                Divider()

                                VStack {
                                    ProgressView(value: torrent.progress)
                                        .frame(width: 100)
                                    Text("\(Int(torrent.progress * 100))%")
                                        .frame(width: 100, alignment: .center)
                                }

                                Divider()

                                Text(torrent.state == "stalledUP" ? "Seeding" : (torrent.state == "pausedUP" ? "Complete" : (torrent.state == "pausedDL" ? "Paused" :
                                    torrent.state)))

                                    .frame(width: 80, alignment: .center)

                                Divider()

                                Text("\(torrent.dlspeed / 1024) kB/s")
                                    .frame(width: 100, alignment: .center)
                            }
                            .padding(.vertical, 8)
                            .background(Color.clear)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color.clear)
        }
        .onAppear {
            torrentData.authenticateAndFetchTorrents()
        }
        .padding()
        .background(Color.clear)
        .frame(minWidth: 600, minHeight: 400)  
    }
}

#Preview {
    ContentView()
}
