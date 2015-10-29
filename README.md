Project Chat Server

Approach : 

Used websockets throughout the project. From login, signup to signup, chatting, everything is communicated from client interface to backend erlang chat server is via websockets. I used it because to get myself more familiarized with websockets( since there are better ways to handle login signup etc. ).
 
The Flow :
The client interface(frontend) static files is hosted via the Cowboy server.

The backend ( gen_server ) is connected to it and has many handlers which handle events from the frontend.

The backend then, whenever required, talks to the Mnesia dB for various data requirements and returns the apt values which then the handler handles and returns results to the respective interfaces.
 

Backend :
The Application Supervisor manages the server and application. The gen_server is started and cowboy handles the connections.
Cowboy spawns separate processes for each connection, makes them communicate with the server to exchange messages.
The information stored in Mnesia database are : 
   user {username,password}   ->   for login/signup check.
   chatroom {cname,id}  ->  for chatroom names.
   in_chatroom {chatroom,users = []}  ->  for getting users inside a chatroom.
   userpid {username,pid}  ->  for sending messages to particular users inside a chatroom.


Overview :
Users can create unique usernames with passwords through signup page and then after login using the same, user is redirected to the chatrooms page.
Here all the existing chatroom names appear. User can either join one or create a new one. Either choice redirects to the main chatroom page.
Now the user can chat on the main page and leave the chatroom.
 
There is also a Admin page which can delete users and chatrooms.

Improvements that can be done:
Show statistics of users, chatrooms like number of messages, number of chatrooms etc.
Use RESTAPI or other better handlers for login/signup.
