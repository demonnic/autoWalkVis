# Walk Visualizer

This package allows you to highlight rooms based on how many times you've revisited them during your current autowalk or manual exploration.

Only been there once? It's highlighted a cool, calming green.

Been there 5 times? RED ALERT!

Primarily designed to watch the dots fill in while doing an auto walk, but also to see where it is least efficient, hence the colors getting redder the more you visit.

## Requirements

It uses the `gmcp.Room.Info` event to determine it's entered a room, and the value of `gmcp.Room.Info.num` to determine which room it was. So if your game doesn't have this, you're out of luck. Should work with all IREs and any game which models its gmcp after the IRE ones.

## Aliases

* `awv start`
  * starts the visualizer, clearing any previously highlighted rooms it is tracking
* `awv stop`
  * stops adding the highlights but does not clear them out, so you can look over them and run the report
* `awv clear`
  * stops the visualizer and clears all the highlights.
* `awv report`
  * prints a report on number of rooms visited, number of moves to do it, etc.

## API

* `autoWalkVis:start()`
  * starts the visualizer, clearing any previously highlighted rooms it is tracking
* `autoWalkVis:stop(clear?)`
  * stops the visualizer. If argument is true, also clears all the highlights. Data is kept either way for reports.
* `autoWalkVis:report()`
  * prints out the stat report for this visualization session
* `autoWalkVis:clearHighlights()`
  * clears all the map highlights without clearing the data. Leaves the visualizer on/off state alone.
* `autoWalkVis:resetGradientAndHighlights()`
  * This looks over the data and resets the max level of the gradient from 5 to whatever the most times a room was visited was. Then it goes through and adjusts the highlights on all tracked rooms to use the new gradient. Useful if you have a walk which simply must revisit some rooms more than 5 times and want to change the scale for better visualization.
