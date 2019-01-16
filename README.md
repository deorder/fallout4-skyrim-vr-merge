# fallout4-skyrim-vr-merge
Merge Fallout 4 and/or Skyrim SE with their VR counterparts by comparing MD5 hashes using symbolic links

## Description

Unlike other merge scripts this one merges game assets by comparing the files in the game`s `data` folder using MD5 hashes to know what to link.

## Installation

Put the `.bat` and `.ps1` files inside a directory that contains both (`Skyrim Special Edition` and `SkyrimVR`) and/or (`Fallout 4` and `Fallout 4 VR`).

## Usage

- Run the appropiate `.bat` file of the game you want to merge. **Note:** You will be asked to run the script as an admin
- After the merge verify that the VR version of the game works. Try starting a save game.
- If everything is okay you can remove all `.org` files in the game's `data` directory.

## Revert

- Use `Verify Local Files` in Steam
