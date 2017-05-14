## FA-Coop Deployment

These parts need to be deployed:

* Maps (from faf-coop-maps repo)
* Voice-Overs (from https://github.com/FAForever/fa-coop/releases/tag/v49)
* Mod (from here)

The Voice-Overs are part of the Mod, but due to their big binary sizes not included in the git repo.

The Mod patcher script has special logic to just read the checksum of the deployed voice-over packages to update their db entries.

### Maps

* Go to `/opt/....../fa-coop/faf-coop-maps` and update (`git fetch`, then `git checkout` the tag)
* Run `./make_all.sh`

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
