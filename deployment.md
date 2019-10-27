## FA-Coop Deployment

These parts need to be deployed:

* Maps (from faf-coop-maps repo)
* Voice-Overs (from https://github.com/FAForever/fa-coop/releases/tag/v49)
* Mod (from here)

The Voice-Overs are part of the Mod, but due to their big binary sizes not included in the git repo.

The Mod patcher script has special logic to just read the checksum of the deployed voice-over packages to update their db entries.

### Maps

#### Updating
* Go to `/opt/....../fa-coop/faf-coop-maps` and update (`git fetch`, then `git checkout` the tag)
* Run `./make_all.sh`

#### Adding a new map
Insert new records into table `coop_map`. As type use `4` (custom coop map). Write down the id of the new record.
Edit the `make_path.sh` in the faf-coop-maps folder. Add the new map folder in the declarative arrays MAP_IDS and MAP_TYPES. For MAP_IDS use the record id from the SQL row. For MAP_TYPES use the same type as in the SQL row.
Now follow the regular instructions for update.

### Voice-Overs

Grab the files:

    curl https://api.github.com/repos/FAForever/fa-coop/releases/latest | jq -r '.assets | map(.browser_download_url | select (. | contains("nx2"))) | .[]' | xargs wget

Rename them to correct version:

    rename 's/\./.v49./' *.nx2

Copy them:

    cp *.nx2 /opt/....../files/

Make sure to `chown` and `chmod` correct.

## Mod

* Go to `/opt/....../fa-coop` and update
* Run `./make_patch.py`

That should be it!
