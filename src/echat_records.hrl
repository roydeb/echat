-record (user, {name,password}).
-record (chatroom, {cname,id}).
-record (in_chatroom, {chatroom,users=[]}).
-record (chat_messages, {cname,username,message}).