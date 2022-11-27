 ## Replacer Tool

Replacer tool for creative building in [Minetest](http://minetest.net) is helpful for copying, placing and replacing nodes. The tool can place or replace existing nodes with a previously selected other type of node (i.e. places said windows into a brick wall) preserving rotations of the copied node.

### Crafting the replacer:   
chest | _____ | _____ 

_____ | stick | _____

_____ | _____ | chest 

### Commands
Give yourself a replacer (priv required) `/giveme replacer:replacer`

Set replacer modes (paint/legacy) `/replacer legacy` `/replacer paint`

### Paint mode controls (default)
   The controls allow players continuously place or replace nodes by holding down right mouse key (Shift for replace)

   `Shift + Left Mouse`:  Set replacer's replacement node data (node to be placed)
   
   `Left Mouse`:          Replace pointed node with replacement node.
   
   `Right Mouse`:         Place replacement node on pointed node (normal placement) continuously while keys are held.
   
   `Shift + Right Mouse`: Replace pointed node with replacement node continuously while keys are held

### Legacy mode controls
   `Right Mouse` Place replacement node on pointed face.
  
   `Left Mouse`: Replace pointed node with replacement node.
   
   `Shift + Right Mouse`: Set replacer's replacement node data (node to be placed)

### Inventory and Creative mode support
When not in creative mode, digging will be simulated when replacing nodes, giving the player any drops. In return, the replacement node will be taken from your inventory.

When in minetest game's creative mode, the node will just be replaced. Your inventory will not be changed.

## Inspector tool
   The inspector tool shows information about the pointed node.

###Crafting:    
torch

stick

Just wield it and click on any node or entity you want to know more about. A limited craft-guide is included.

### License
-- Copyright 2021 Sokomine, lumberJack, Vanessa E

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
### Change log: 
- 11.27.2021   
   - Add mode setting for paint and legacy keybindings
   - Code and documentation cleaned up and updated.
- 2020         
   - Added HUD support and remove chat messages
   - Added new keybinding to allow paint mechanic while replacing nodes

#### Forked from Sokomine 

-- 09.12.2017 * Got rid of outdated minetest.env
--            * Fixed error in protection function.
--            * Fixed minor bugs.
--            * Added blacklist
-- 02.10.2014 * Some more improvements for inspect-tool. Added craft-guide.
-- 01.10.2014 * Added inspect-tool.
-- 12.01.2013 * If digging the node was unsuccessful, then the replacement will now fail
--              (instead of destroying the old node with its metadata; i.e. chests with content)
-- 20.11.2013 * if the server version is new enough, minetest.is_protected is used
--              in order to check if the replacement is allowed
-- 24.04.2013 * param1 and param2 are now stored
--            * hold sneak + right click to store new pattern
--            * right click: place one of the itmes 
--            * receipe changed
--            * inventory image added
    
-- adds a function to check ownership of a node; taken from VanessaEs homedecor mod