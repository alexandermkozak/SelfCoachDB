# SelfCoachDB
Self Coach DB

### About
This was a small project for tinkering with [MVConnect](https://docs.rocketsoftware.com/bundle/pdy1647626978888/page/jlw1647626979784.html) in [OpenQM](https://www.openqm.com/) to provide basic REST APIs backed by a multi value database.

### Structure
Below is a brief description of the intended structure for files

#### API.OBJ
These are the plain old Basic object files used to support the API 

#### API.SYS
These are the basic programs executed to support greater functionality with respect to any API functions. Shared logic, business logic, etc. go here.

#### BUILD.BP
This contains any and all build resources needed to execute to build or rebuild systems after updates. The intention is to allow the install and update processes
to be automated in the future.

#### BUILD.DICTIONARIES
This should contain dictionary items and resources needed to deploy them. This ensures that backups and change management are applied not only to programs, 
but also to dictionaries and file structure.

#### PHANTOM.BP
This contains basic programs to be executed as a phantom. Examples include a session cleanup service

#### PHANTOM.SYS
This contains supporting basic programs for phantoms. Shared logic, business logic, etc. go here.

#### REST.API.BP
This contains the controllers for APIs. These should be fairly simple programs meant to handle standard HTTP requests. These should do basic input, routing, and response logic.
These should execute programs found in **API.SYS** for actual business logic.

#### TEST.SCRIPTS
This currently contains simple test scripts for manual testing of **API.SYS** files.

#### WDB.RESOURCE
This contains standard routing records used by MVCONNECT to attach controllers to incoming routes.

### Deployment
Deployment instructions should go here!

### Testing
Testing instructions should go here!

### Getting Started
This should really be at the top of the readme, and any work needed for someone to get started working with the project would go here!
