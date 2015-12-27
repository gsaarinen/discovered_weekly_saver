# Spotify Pomodoro

### Warning: This script fires from the hip and doesn't die gracefully. YMMV.

For reference: [The Pomodoro Technique](http://pomodorotechnique.com/)

This is a simple script that uses the Faraday API to interact with the Spotify Web API.

It pulls from a source playlist that the user has defined as an environment variable and creates a new playlist of songs that adds up to around 25 minutes. Nothing more, nothing less.

I don't even want to bother telling you how to get the right authorization codes from Spotify. Just .. ugh.
This is not for the faint of heart. Spotify made me jump through lots of hoops.

If you want to use this for yourself, you're going to have to have following:

- Spotify App Client ID
- Spotify App Client SECRET
- Source Playlist ID
- Refresh Token (from the 'Authorization Code Flow')

To get your own Refresh Token, start here:
https://developer.spotify.com/web-api/authorization-guide/#authorization_code_flow

For step #1 you can follow the `/authorize` URL in your browser and accept the Spotify permissions. For `scope` in generating the URL I used `playlist-modify-private`.
 Once you follow the URL and are brought back to the redirect-uri, you will then be presented with a URL in your address bar that has `?code=` in it. That's the code you need to follow step #4 from the Spotify Authorization maze. This was hard to figure out. You're welcome.

Please join me in celebrating my very first AUTOMATICALLY CREATED Pomodoro playlist:

https://play.spotify.com/user/1214768777/playlist/6Z7TOUr0bnosHktl54JODi

And here it is, embedded:

<iframe src="https://embed.spotify.com/?uri=spotify%3Auser%3A1214768777%3Aplaylist%3A6Z7TOUr0bnosHktl54JODi" width="300" height="380" frameborder="0" allowtransparency="true"></iframe>

---

Oh my god, and thank you to [Faker](https://github.com/stympy/faker) for the lovely gem that I am using to randomly generate the Playlist names. They're hilarious every time.

---
Godspeed.
