import Foundation
import AppKit

@Observable
@MainActor
final class NowPlayingService {
    var nowPlaying = NowPlayingInfo()
    var isAvailable: Bool = false

    private var refreshTimer: Timer?

    // MediaRemote 動態載入
    private typealias MRMediaRemoteGetNowPlayingInfoFunction =
        @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    private typealias MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction =
        @convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void

    private var getNowPlayingInfo: MRMediaRemoteGetNowPlayingInfoFunction?
    private var getIsPlaying: MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction?

    init() {
        loadMediaRemote()
    }

    // MARK: - MediaRemote 動態載入

    private func loadMediaRemote() {
        let path = "/System/Library/PrivateFrameworks/MediaRemote.framework"
        guard let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: path)) else {
            isAvailable = false
            return
        }

        if let ptr = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) {
            getNowPlayingInfo = unsafeBitCast(ptr, to: MRMediaRemoteGetNowPlayingInfoFunction.self)
        }

        if let ptr = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying" as CFString) {
            getIsPlaying = unsafeBitCast(ptr, to: MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction.self)
        }

        isAvailable = getNowPlayingInfo != nil
    }

    // MARK: - 啟動 / 停止

    func startUpdating() {
        fetchNowPlaying()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.fetchNowPlaying()
            }
        }
    }

    func stopUpdating() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    // MARK: - 取得正在播放的音樂

    private func fetchNowPlaying() {
        if isAvailable {
            fetchViaMediaRemote()
        } else {
            fetchViaAppleScript()
        }
    }

    private func fetchViaMediaRemote() {
        guard let getNowPlayingInfo else { return }

        getNowPlayingInfo(DispatchQueue.main) { [weak self] info in
            guard let self else { return }

            self.nowPlaying.title = info["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? ""
            self.nowPlaying.artist = info["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? ""
            self.nowPlaying.album = info["kMRMediaRemoteNowPlayingInfoAlbum"] as? String ?? ""
            self.nowPlaying.duration = info["kMRMediaRemoteNowPlayingInfoDuration"] as? TimeInterval ?? 0
            self.nowPlaying.elapsedTime = info["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? TimeInterval ?? 0

            if let artworkData = info["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
                self.nowPlaying.artworkData = artworkData
            }
        }

        getIsPlaying?(DispatchQueue.main) { [weak self] playing in
            self?.nowPlaying.isPlaying = playing
        }
    }

    // MARK: - AppleScript 備用方案

    private func fetchViaAppleScript() {
        // 嘗試 Apple Music
        let musicScript = """
        tell application "System Events"
            if exists (process "Music") then
                tell application "Music"
                    if player state is playing then
                        set trackName to name of current track
                        set trackArtist to artist of current track
                        set trackAlbum to album of current track
                        set trackDuration to duration of current track
                        set trackPosition to player position
                        return trackName & "|||" & trackArtist & "|||" & trackAlbum & "|||" & (trackDuration as text) & "|||" & (trackPosition as text)
                    end if
                end tell
            end if
        end tell
        return ""
        """

        if let result = runAppleScript(musicScript), !result.isEmpty {
            parseAppleScriptResult(result, isPlaying: true)
            return
        }

        // 嘗試 Spotify
        let spotifyScript = """
        tell application "System Events"
            if exists (process "Spotify") then
                tell application "Spotify"
                    if player state is playing then
                        set trackName to name of current track
                        set trackArtist to artist of current track
                        set trackAlbum to album of current track
                        set trackDuration to (duration of current track) / 1000
                        set trackPosition to player position
                        return trackName & "|||" & trackArtist & "|||" & trackAlbum & "|||" & (trackDuration as text) & "|||" & (trackPosition as text)
                    end if
                end tell
            end if
        end tell
        return ""
        """

        if let result = runAppleScript(spotifyScript), !result.isEmpty {
            parseAppleScriptResult(result, isPlaying: true)
            return
        }

        // 沒有播放中的音樂
        nowPlaying.isPlaying = false
    }

    private func runAppleScript(_ source: String) -> String? {
        var error: NSDictionary?
        guard let script = NSAppleScript(source: source) else { return nil }
        let result = script.executeAndReturnError(&error)
        return result.stringValue
    }

    private func parseAppleScriptResult(_ result: String, isPlaying: Bool) {
        let parts = result.components(separatedBy: "|||")
        guard parts.count >= 5 else { return }

        nowPlaying.title = parts[0]
        nowPlaying.artist = parts[1]
        nowPlaying.album = parts[2]
        nowPlaying.duration = Double(parts[3]) ?? 0
        nowPlaying.elapsedTime = Double(parts[4]) ?? 0
        nowPlaying.isPlaying = isPlaying
    }

    nonisolated deinit {
        // Timer 會在被釋放時自動停止
    }
}
