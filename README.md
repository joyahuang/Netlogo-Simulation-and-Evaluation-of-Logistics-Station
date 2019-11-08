# Netlogo-Simulation-and-Evaluation-of-Express-Delivery-Station
Let me help mailman survice the 11 Nov Crazy Sale!
Team: Zhuoya Huang, Yanhan Pan, Zichen Liu. Tutor: Wei Zhu

## Background
With the improvement of people's living standards, people's demand for express delivery services is also increasing. Under this background, a comprehensive logistics service platform for consumers, such as regional Courier express delivery service center, has emerged, which is committed to solving the needs of residents for sending and receiving express in the last 100 meters from home. At present, regional express service stations provide door-to-door pick-up service. Residents can put the express in the Courier station, and then receive it uniformly by the Courier, and then send it through the station.

## Target
Based a residential area of a certain scale (population, area) , what is the site selection, quantity and scale of regional courier express service station to meet the needs of residents for delivery.

## Model
### Agent1: mailman: the delivery agent
Property|Explanation
-|-
goal?|Does he have a target mailbox,?
carryingnum | The amount of delivery he is carring
full? | Does he over loaded?
manmaxnum | The capacity of the mailman agent
alongpoints|The joints on the shortest path to goal 
step|Steps taken on the shortest path
speed|Moving speed on the shortest path 
father|The base(regional station) the mailman belongs to

Action|Explanation
-|-
find-goal|1.If carryingnum<manmannum and explode?=True mailbox, then find the nearest overloaded mailbox. 2. If carryingnum<manmannum and no explode?=True mailbox, then find the nearest mailbox. 3.If carryingnum>=manmannum, the mailman go back to father base.
move-to-goal|Find the shortest path and move along it. When reached the goal, initiate "pick".
pick|1.Go back to father base to unload, that is the carriednum+=carryingnum, carryingnumber=0. 2.Initiate "find-goal"

### Agent2: mailbox: the service station in residential areas
Property|Explanation
-|-
num|Mails in the mailbox
maxnum|Capacity of the mailbox
explode?|Does the mailbox overloaded?
t|The amount of time of overloaded situation.
chosen?|Does a mailman have been assigned to solve the explode situation?
people|The population the mailbox has to serve.
  

Action|Explanation
-|-
create-mails|Mails num will generate in the mailbox based on the population. When explode?=True, this process will stop.



### Agent3: base: the regional service station
Property|Explanation
-|-
capicity|Capacity of the base
carriednum|The amount of mails in the base.






