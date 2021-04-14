use mpd::Client;
use mpd::error::Error;

fn main() -> Result<(), Error> {
    // Get client connecting to MPD server
    let mut client = match Client::connect("localhost:6600") {
        Ok(c) => c,
        Err(e) => return Err(e)
    };
    // Get first song
    let first = match client.currentsong() {
        Ok(c) => c,
        Err(e) => return Err(e)
    };
    // Loop while the song plays
    while let Ok(next) = client.currentsong() {
        if next != first {
            break;
        }
    }
    Ok(())
}
