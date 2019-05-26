# Replacement tool for creative building (Minetest mod)

This tool is helpful for creative purposes (for example, building a wall then
"painting" windows into it). It replaces nodes with a previously-selected
node (i.e. places said windows into a brick wall).

## Crafting

```text
chest  -      -
-      stick  -
-      -      chest
```

Or just use `/giveme replacer:replacer`.

## Usage

- <kbd>Right-click</kbd> on a node of that type you want to replace
  other nodes with.
- <kbd>Left-click</kbd> (normal usage) on any nodes you want to replace
  with the type you previously right-clicked on.
- <kbd>Shift + Right-click</kbd> to store a new pattern.

When in creative mode, the node will just be replaced; your inventory
won't be changed.

When *not* in creative mode, digging will be simulated and you will get
what was there. In return, the replacement node will be taken from
your inventory.

The second tool included in this mod is the inspector.

### Crafting the inspector

```text
torch
stick
```

Just wield it then click on any node or entity you want to know more about.
A limited crafting guide is included.

## License

Copyright (C) 2013, 2014, 2015 Sokomine

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
