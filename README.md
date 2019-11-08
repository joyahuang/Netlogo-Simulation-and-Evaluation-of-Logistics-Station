# Netlogo-Simulation-and-Evaluation-of-Express-Delivery-Station
Let me help mailman survice the 11 Nov Crazy Sale!
Team: Zhuoya Huang, Yanhan Pan, Zichen Liu. Tutor: Wei Zhu

## Background
With the improvement of people's living standards, people's demand for express delivery services is also increasing. Under this background, a comprehensive logistics service platform for consumers, such as regional Courier express delivery service center, has emerged, which is committed to solving the needs of residents for sending and receiving express in the last 100 meters from home. At present, regional express service stations provide door-to-door pick-up service. Residents can put the express in the Courier station, and then receive it uniformly by the Courier, and then send it through the station.

## Target
Based a residential area of a certain scale (population, area) , what is the site selection, quantity and scale of regional courier express service station(we use mailbox to refer service station in this model) to meet the needs of residents for delivery.

## Model
### Agent1: mailman
Property|Explanation
-|-
goal?|Does he have a target mailbox,?
carryingnum | The amount of delivery he is carring
full? | Does he over loaded
manmaxnum | The capacity of the mailman agent
alongpoints|The joints on the shortest path to goal 
step|Steps taken on the shortest path
speed|Moving speed on the shortest path 
father|The mailbox the mailman belongs to

Action|Explanation
-|-
find-goal|1.If not reach the mailman capacity and have a overloaded mailbox, then find the nearest overloaded mailbox. 2. If not reach the mailman capacity and no overloaded mailbox, then find the nearest mailbox. 3.If reach the mailman capacity, the mailman go back to father mailbox.
move-to-goal|Find the shortest path and move along it. When reached the goal, initiate "pick".
pick|1.Go back to father mailbox to unload, that is the carrying number becomes zero. 2.Initiate "find-goal"

### Agent2: mailbox
  
 




