extern crate mpd;

use mpd::Client;

fn main() {
    // Client
    let mut client = Client::connect("localhost:6600").unwrap();
    let current = client.currentsong().unwrap();
    while current == client.currentsong().unwrap() {}
}
