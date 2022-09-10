open 'BLOG.POSTS' to f.posts else null
open 'BLOG.METADATA' to f.metadata else null

post.name = "my-second-blog-post"

metadata.rec = ""
metadata.rec<1> = "A test blog post!"
metadata.rec<2> = date() ; * created date
metadata.rec<3> = date() ; * last update date
metadata.rec<4> = "kojaxinator" ; * by users

blog.rec = ''
blog.rec<1> = "# This is the title of my blog post!"
blog.rec<2> = "### This is the first sub-heading of my blog post"
blog.rec<3> = "This is some text for my first sub-heading of my blog post.  "
blog.rec<4> = "This is another line, and it's even going to have a numbered list:  "
blog.rec<5> = "1. First point of my numbered list."
blog.rec<6> = "2. Second point"
blog.rec<8> = "------"
blog.rec<10> = "### Second sub heading!"
blog.rec<11> = "Man, I don't know what else to put here. But **this** is *bold*!"

write metadata.rec on f.metadata, post.name 
write blog.rec on f.posts, post.name 

crt "Complete!"
end