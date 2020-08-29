# Pogify's message hub
 This is where all of the data are broadcasted to listeners. It needs to be lightweight to support a lot of streamers, but also allow us to perform authorization and the like.

## Dev-ing

You can just run the container as is, the secret (auth header) is set to "" by default (an empty string). If you want, you can change it via the `PUBSUB_SECRET` environment variable that you pass to the container.
