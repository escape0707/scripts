import json
import math
from pathlib import Path

p = Path(".")
subdirectory_collection = [x for x in p.iterdir() if x.is_dir()]

for album_dir in subdirectory_collection:
    album_id = album_dir.name
    album_list_json = album_dir.parent / (album_dir.name + "list.json")
    track_info_collection = json.loads(album_list_json.read_bytes())
    track_info_collection_by_id = {
        info["trackId"]: info for info in track_info_collection
    }
    album_title = track_info_collection[0]["albumTitle"]

    # album_dir = album_dir.rename(album_dir.with_name(album_title))
    print(album_dir.with_name(album_title))

    index_width = int(math.log10(len(track_info_collection))) + 1
    for index, track_path in enumerate(album_dir.iterdir(), 1):
        track_id = int(track_path.stem)
        track_info = track_info_collection_by_id[track_id]
        track_title = str(index).zfill(index_width) + "_" + track_info["title"]
        # track_path.rename(track_path.with_stem(track_title))
        print(track_path.with_stem(track_title))
