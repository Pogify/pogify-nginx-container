# Pogify's message hub
 This is where all of the data are broadcasted to listeners. It needs to be lightweight to support a lot of streamers, but also allow us to perform authorization and the like.

## Dev-ing

You can just run the container as is, the secret (auth header) is set to "" by default (an empty string). If you want, you can change it via the `PUBSUB_SECRET` environment variable that you pass to the container.  
To create a test session, you can run the script `test-session.sh` by specifying the JSON (we included a `test-data.json`) as first argument, and the adress where Nginx is running as a second one.  
A typical invocation would look like:
```
./test-session.sh test-data.json "" "http://localhost/pub?id=dev"
```
Then, you can access the test channel by going to http://localhost:3000/session/dev directly (the input won't work since it restrict to a minimum of 5 characters)