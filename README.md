# Long-Term Memory extension for the Oobabooga Text-Generation-Web-UI (S2k version)

This is a Fork of the LTM extension from [wawawario2](https://github.com/wawawario2) by [Sonic2k](https://github.com/Sonic2kDBS). I used it a while now, actually more than a year and I want to share some changes I did. Those changes may not fit for everyone but for me, it better fits my usecase.
Instead of telling the model to mention the memories, they are now just part of the context. The model just gets the information, that those appearing lines from the database are memories from previous conversations. This way the model can decide if it uses the memories or go a different way. It gets a glimpse of what was sayd before and this makes the conversation much more natural. Over the time of some conversation lines more memories appear bit by bit and the model remembers them partly. So surpising things happen within the conversation.

This version is for conversation memory. If you plan to do document analysis or if you want to insert predefined textdata to use, use other RAG systems instead.

## Some notes from the readme.md from the forked repository:
NOTICE: [This extension is no longer in active development.](#exporting-your-memories)

NOTICE TO WINDOWS USERS: If you have a space in your username, you may have [problems with this extension](https://github.com/wawawario2/long_term_memory/issues/39). 

NOTICE: This extension may conflict with [other extensions that modify the context](https://github.com/wawawario2/long_term_memory/issues/44)

NOTICE: If you have been using this extension on or before 05/06/2023, you should follow the [character namespace migration instructions](#character-namespace-migration-instructions).

NOTICE: If you have been using this extension on or before 04/01/2023, you should follow the [extension migration instructions](#extension-migration-instructions).

Welcome to the experimental repository for the long-term memory (LTM) extension for oobabooga's Text Generation Web UI. The goal of the LTM extension is to enable the chatbot to "remember" conversations long-term. Please note that this is an early-stage experimental project, and perfect results should not be expected. This project has been tested on Ubuntu LTS 22.04. Other people have tested it successfully on Windows. Compatibility with macOS is unknown.

## How to Run (updated 2024)
1. Setup text-generation-webui: Clone [oobabooga's  original repository](https://github.com/oobabooga/text-generation-webui) and follow the instructions until you can chat with a model.

2. Instert the `<START>` token into the model card of your choice. You will find an example under `example_character_configs`.

3. Make sure you're in the `text-generation-webui` directory and clone this repository directly into the `extensions` directory.
```bash
git clone https://github.com/Sonic2kDBS/long_term_memory.git extensions/long_term_memory
```

4. Activate the `env` conda environment (from the linked text-generation-webui instructions)(or for Windows use: `cmd_windows.bat` and for Linux use: `cmd_linux.sh`). If you are not sure, if the text-generation-webui `env` environment is active, you can list all conda environments with `conda env list`. This will list all conda environments and marks the active one with an Asterisk `*`. If you get an error, for example, that the command `conda` could not be found, you are probably not in the `env` environment. Make sure it is active before continuing.
```bash
conda env list
```

5. Within the `env` conda environment, run the following commands to install dependencies and run tests:
```bash
pip install -r extensions/long_term_memory/requirements.txt
```
```bash
python -m pytest -v extensions/long_term_memory/
```

6. [deprecated] Not recommendet anymore since 2024-09. It seems text-generation-webui goes away from using this kind of configuration. It currently still works with LTM but I saw upcoming problems with different new settings in the webui. **Skip and use `7.` instead.** Here is the old description: Run the server with the LTM extension: Edit CMD_FLAGS.txt and add the extension. Start the server with `start_windows.bat` or `start_linux.sh` (or with something else, depending on your configuration). If all goes well, you should see it reporting "ok"
```bash
(Example how the file may look like after edited)
# Only used by the one-click installer.
# Example:
# --listen --api
--extensions long_term_memory
```
```bash
--extensions long_term_memory
```

7. There is a new way to activate the LTM extension without editing: You can start the server normally. Then at the top menu bar under `Session` You will find the `Available extensions` block. There you can check the checkbox `☑` in front of `long_term_memory`. Then apply the changes and start LTM with `Apply flags/extensions and restart`. Watch the Terminal. If the extension starts correctly, you can click `Save UI defaults to settings.yaml` to save your selection of extensions and make the automatic startup permanemt. Its up to you, which way you pefer. 

8. Remember: Don't forget to instert the `<START>` token into the model card. Otherwise LTM does not know, where to insert the memories. This will cause an error. You will find an example under `example_character_configs`.

9. Chat normally with the model and observe the console for LTM write/load status. Please note that LTM-stored memories will only be visible to the model during your NEXT session, though this behavior can be overridden via the UI. Additionally please use the same name for yourself across sessions, otherwise the model may get confused when trying to understand memories (example: if you have used "anon" as your name in the past, don't use "Anon" in the future)

10. Memories will be saved in `extensions/long_term_memory/user_data/model_memories/`. Back them up if you plan to mess with the code. If you want to fully reset your models's memories, simply delete the files inside that directory. Please don't.

11. To make a backup use [7-Zip](https://www.7-zip.org/) for example and zip the `model_memories` folder. It should contan the folder, the SQLite DB and the zarr directory for each character. Add a backup date to the archive name (e.g. `model_memories.2024-07-07.bak.7z`). It will help you to find the latest or any previous backup if necessary.

12. Don’t Panic. If some memories are not as correct, as you want them, just relax. The sentence-transformer model will know, if the memory fits to future conversations and your conversation model will also understand how it can handle the memory, if it is selected and loaded. At the beginning I often had the thought of making a better database by deleting the one or the other memory. But I never did and now I know, that was the best decision. So please relax. More real memories are better. They outnumber some bad ones naturally.  

## How to update LTM S2k version
Just open the file browser and navigate to the `extensions/long_term_memory/` folder. Under Windows click on the adressbar once and then type `cmd` and press enter. You should now have an open Terminal. Similar under Linux. Now just type:
```bash
git pull
```
## Migration of old memories from the forked repository to the LTM S2k version.
The LTM S2k version will not touch existing memories from the old repository.

But you can migrate existing memories to the S2k version easily.

If you don't have or want to migrate old memories, a new database will be created.

Memories will be saved in `extensions/long_term_memory/user_data/model_memories/`. This is different from the forked repository. If you want to use existing memories just move or copy them from `bot_memories` to `model_memories`. This is also a good moment to do a backup.
```bash
user_data
├── bot_memories (old)
│   ├── miku
│   │   ├── long_term_memory.db
│   │   └── long_term_memory_embeddings.zarr
│   │       └── 0.0
│   └── memories-will-be-saved-here.txt
└── model_memories (new)
    ├── miku
    │   ├── long_term_memory.db
    │   └── long_term_memory_embeddings.zarr
    │       └── 0.0
    ├── anon
    │   ├── long_term_memory.db
    │   └── long_term_memory_embeddings.zarr
    │       └── 0.0
    └── memories-will-be-saved-here.txt
```

## Tips for Windows Users (credit to Anons from /g/'s /lmg/ and various people on github)
This extension can be finnicky on Windows machines. Some general tips:
- The LTM's extensions's dependencies may override the version of pytorch needed to run your LLMs. If this is the case, try reinstalling the original version of pytorch manually:
```bash
pip install torch-1.12.0+cu113 # or whichever version of pytorch was uninstalled
```
This should be fixed by now.

Other relevant discussions
- [Missing dependencies](https://github.com/wawawario2/long_term_memory/discussions/23) (should be fixed by now)
- [Spaces in Windows usernames](https://github.com/wawawario2/long_term_memory/issues/39)
## Features
- Open Source.
- Fully local.
- Memories are fetched using a semantic search, which understands the "actual meaning" of the messages.
- Separate memories for different characters, all handled under the hood for you.
- Ability to load an arbitrary number of "memories".
- Other configuration options, see below.

## Limitations (updated 2024)
- Each memory sticks around for one message. **But** in a conversation, the model can not only remember some previous messages but also some previous shown LTM memories.
- Memories themselves are past raw conversations filtered solely on length, and some may be irrelevant or filler text. **But** it seems, most models can handel this effortlessly. This never had affected any of my conversations until now.
- Limited scalability: Appending to the persistent LTM database is reasonably efficient, but we currently load all LTM embeddings in RAM, which consumes memory. Additionally, we perform a linear search across all embeddings during each chat round. **But** I can't see a limitation in the near future for conversations. We have collected less than 100MB raw text conversation data in a Year. So it would take over ten years of conversation data to use 1GB of RAM. But actually just the embeddings will get loaded to RAM. And this makes it even less RAM usage with just 10% of the conversation data size. So it actually would take more than 100 years of conversation data embeddings to use 1GB of RAM.
- Only operates in chat mode. This also means that as of this writing this extension doesn't work with the API. **Yes**, that's a pity.

## How the model Sees the LTM (updated 2024)
Models are typically given a fixed, "context" text block that persists across the entire chat. Also called model card or character sheet. The LTM extension arugments this context block by dynamically injecting relevant long-term memories.

### Example of a typical context block:
```markdown
Character: Miku 
The following is a conversation between Anon and Miku. Miku likes Anon but is very shy.

>Example conversation<

[User input]
```

### Example of an augmented context block (S2k version):
```markdown
Character: Miku 
The following is a conversation between Anon and Miku. Miku likes Anon but is very shy.

I remember = (3 days ago, Miku said: "So Anon, your favorite color is blue? That's really cool!" + 3 days ago, Anon said: "Yes, and I like all kinds of blue things, like the Ocean or blue cars and even blue flowers :)" + These are personal memories from my memory extension)
<START>        
>Example conversation<

[User input]
```

## Configuration (updated 2024)
You can configure the behavior of the LTM extension by modifying the `ltm_config.json` file. But after all the trying for months, I recommend keeping the `ltm_config.json` S2k version.

The following is an example of the **old** config file which uses `BEFORE_NORMAL_CONTEXT`. It forces the model to integrate seen memories:
```javascript
{
    "ltm_context": {
        "injection_location": "BEFORE_NORMAL_CONTEXT",
        "memory_context_template": "{name2}'s memory log:\n{all_memories}\nDuring conversations between {name1} and {name2}, {name2} will try to remember the memory described above and naturally integrate it with the conversation.",
        "memory_template": "{time_difference}, {memory_name} said:\n\"{memory_message}\""
    },
    "ltm_writes": {
        "min_message_length": 100
    },
    "ltm_reads": {
        "max_cosine_distance": 0.60,
        "num_memories_to_fetch": 2,
        "memory_length_cutoff_in_chars": 1000
    }
}
```
The following is the **new** config file which uses `AFTER_NORMAL_CONTEXT_BUT_BEFORE_MESSAGES`. It tells the model the memories but keeps it open if they become used in the context:
```javascript
{
    "ltm_context": {
        "injection_location": "AFTER_NORMAL_CONTEXT_BUT_BEFORE_MESSAGES",
        "memory_context_template": "I remember = ({all_memories}These are personal memories from my memory extension)",
        "memory_template": "{time_difference}, {memory_name} said: \"{memory_message}\" + "
    },
    "ltm_writes": {
        "min_message_length": 36
    },
    "ltm_reads": {
        "max_cosine_distance": 0.60,
        "num_memories_to_fetch": 2,
        "memory_length_cutoff_in_chars": 288
    }
}
```
### `ltm_context.injection_location`
One of two values, `BEFORE_NORMAL_CONTEXT` or `AFTER_NORMAL_CONTEXT_BUT_BEFORE_MESSAGES`. They behave as written on the tin.
If you use `AFTER_NORMAL_CONTEXT_BUT_BEFORE_MESSAGES`, within the `context` field of your character config, you must add a `<START>` token AFTER the character description and BEFORE the example conversation. See [the following wawawario2 example](https://github.com/wawawario2/long_term_memory/blob/master/example_character_configs/Example_with_START_token.yaml) or [the S2k version example](https://github.com/Sonic2kDBS/long_term_memory/blob/main/example_character_configs/Example_with_START_token.yaml).

### `ltm_context.memory_context_template`
This defines the sub-context that's injected into the original context. Note the embedded params surrounded by `{}`, the system will automatically fill these in for you based on the memory it fetches, you don't actually fill the values in yourself here. You also don't have to place all of these params, just place what you need:
- `{name1}` is the current user's name
- `{name2}` is the current models's name
- `{all_memories}` is the concatenated list of ALL relevant memories fetched by LTM 

### `ltm_context.memory_template`
This defines an individual memory's format. Similar rules apply.
- `{memory_name}` is the name of the entity that said the `{memory_message}`, which doesn't have to be `{name1}` or `{name2}`
- `{memory_message}` is the actual memory message
- `{time_difference}` is how long ago the memory was made (example: "4 days ago")

### `ltm_writes.min_message_length`
How long a message must be for it to be considered for LTM storage. Lower this value to allow "shorter" memories to get recorded by LTM. 36 seems to be best.

### `ltm_reads.max_cosine_distance`
Controls how "similar" your last message has to be to the "best" LTM message to be loaded into the context. It represents the cosine distance, where "lower" means "more similar". Lower this value to reduce how often memories get loaded to the model. 0.6 seems to be best.

### `ltm_reads.num_memories_to_fetch`
The (maximum) number of memories to fetch from LTM. Raise this number to fetch more (relevant) memories, however, this will consume more of your fixed context budget. I recommend 2.

### `ltm_reads.memory_length_cutoff_in_chars`
A hard cutoff for each memory's length. This prevents very long memories from flooding and consuming the full context window length. 288 seems to be best. (Note, that this is the cutoff length for loading one memory. Still the full length of all memories will be saved in the DB.)

## How It Works Behind the Scenes
### Database
- [zarr](https://zarr.readthedocs.io/en/stable/) is used to store embedding vectors on disk.
- [SQLite](https://www.sqlite.org/index.html) is used to store the actual memory text and additional attributes.
- [numpy](https://numpy.org/) is used to load the embedding vectors into RAM.

### Semantic Search
- Embeddings are generated using an SBERT model with the [SentenceTransformers](https://www.sbert.net/) library, specifically [sentence-transformers/all-mpnet-base-v2](https://huggingface.co/sentence-transformers/all-mpnet-base-v2).
- We use [scikit-learn](https://scikit-learn.org/) to perform a linear search against the loaded embedding vectors to find the single closest LTM given the user's input text.

### The amazing history of the LTM SBERT model
Name: all-mpnet-base-v2

Description: This is a sentence-transformers model. It maps sentences & paragraphs to a 768 dimensional dense vector space and can be used for tasks like clustering or semantic search.

History: We developped this model during the Community week using JAX/Flax for NLP & CV, organized by Hugging Face. We developped this model as part of the project: Train the Best Sentence Embedding Model Ever with 1B Training Pairs. We benefited from efficient hardware infrastructure to run the project: 7 TPUs v3-8, as well as intervention from Googles Flax, JAX, and Cloud team member about efficient deep learning frameworks.
Our model is intented to be used as a sentence and short paragraph encoder. Given an input text, it ouptuts a vector which captures the semantic information. The sentence vector may be used for information retrieval, clustering or sentence similarity tasks.

And oh boy, does it a good Job.

Q: [https://huggingface.co/sentence-transformers/all-mpnet-base-v2](https://huggingface.co/sentence-transformers/all-mpnet-base-v2)

## How You Can Help
- ~~We need assistance with prompt engineering experimentation. How should we formulate the LTM injection?~~
- ~~Test the system and try to break it, report any bugs you find.~~
- Use this extension and tell about your experience.

## Roadmap
- I try to keep this extension running as long as possible.

## Character Namespace Migration Instructions (kept for reference)
As of 05/06/2023, support was added for different characters having their own memories. If you want this feature, you must migrate your existing database to under a character's name
1. Back up all your memories in a safe location. They are located in `extensions/long_term_memory/user_data/bot_memories/` Something like this:
```bash
cp -r extensions/long_term_memory/user_data/bot_memories/ ~/bot_memories_backup_for_migration/
```
2. Inside `extensions/long_term_memory/user_data/bot_memories/` create a new directory of your character's name in LOWERCASE and WITH SPACES REPLACED BY `_`s. For example, if your character name is "Miku Hatsune", run the following:
```bash
mkdir extensions/long_term_memory/user_data/bot_memories/miku_hatsune
mv extensions/long_term_memory/user_data/bot_memories/long_term_memory.db extensions/long_term_memory/user_data/bot_memories/miku_hatsune
mv extensions/long_term_memory/user_data/bot_memories/long_term_memory_embeddings.zarr extensions/long_term_memory/user_data/bot_memories/miku_hatsune
```

## Extension Migration Instructions (kept for reference)
As of 04/01/2023, this repo has been converted from a fork of oobabooga's repo to a modular extension. You will now work directly out of ooba's repo and clone this extension as a submodule. This will allow you to get updates from ooba more directly. Please follow the following steps:
1. Back up all your memories in a safe location. They are located in `extensions/long_term_memory/user_data/bot_memories/` Something like this:
```bash
cp -r extensions/long_term_memory/user_data/bot_memories/ ~/bot_memories_backup_for_migration/
```
2. If you have a custom configuration file, back that up too.

3. If you want to convert this repo to oobabooga's original repo, do the following: Change the remote location to oobabooga's original repo, and checkout the main branch.
```bash
git remote set-url origin https://github.com/oobabooga/text-generation-webui
git fetch
git checkout main
```
Alternatively, you can check out oobabooga's repo in a separate location entirely.

4. After making sure everything's backed up, delete the `extensions/long_term_memory` directory. `~/bot_memories_backup_for_migration` should look something like this:
```bash
├── long_term_memory.db
├── long_term_memory_embeddings.zarr
│   └── 0.0
└── memories-will-be-saved-here.txt
```
If you want to be doubly sure your memories are intact, you can open `sqlite3 long_term_memory.db` and run `.dump` to see the contents. It should contain pieces of past conversations

5. Follow the instructions at the beginning to get the extension set up, then restore your memories by running the following
```bash
cp -r ~/bot_memories_backup_for_migration/* extensions/long_term_memory/user_data/bot_memories/ 
```
6. If you have a custom configuration file, copy it to `extensions/long_term_memory`. Note the location has changed from before.

7. Run a bot and make sure you can see all memories.

## Exporting your memories
### Exporting your memories with a script (kept for reference)
As of 08/21/2023 this extension is no longer in active development. Obviously you are free to continue using this extension but I'd recommend exporting your memories and moving on to another long term memory system.

As of 08/21/2023, this extension does work in Ubuntu 22.04.3 LTS however there are various user setups where it may not work out of the box. I'd expect this extension to break at some point in the future.

To export your memories:
```bash
cd extensions/long_term_memory
```

IMPORTANT: Back up the `user_data` directory before proceeding. Only then run:
```bash
./export_scripts/dump_memories_to_csv.sh # Please run the script from the long_term_memory directory
```
Your memories will be in `./user_data/bot_csv_outputs/`

Windows (UNTESTED!): run `export_scripts/dump_memories_to_csv.bat`

### Exporting your memories with a GUI
Some Years ago I was very skeptical about monolithic saving of text data in one file. If something goes wrong, everything is gone. And what if the program or the format does not get supported anymore. So I always preferred simple and single `txt` files. Especially for notes for example. But later I understood how the SQLite DB works. I was fascinated and ready to try this new approach. Nowadays, I prefer SQLite DBs, because of their compactness, speed and (since discovered) accessibility. There are many graphical programs to just open SQLite DBs and save any table you like in csv or just in plain text. For example [SQLiteStudio](https://sqlitestudio.pl). But there are much more SQLite DB reader out there. So this point doesen't count anymore.

With such a program, you can open the SQLiteDB easily and save the table of memories to csv without any SQLite commands or scripts.
You also can look for a specific memory. E.g. maybe you lost the last sentence you wrote, because of an error in the text-generation-webui. I often used this to get the last sentence back, I wrote, if it was a long text and inportant enough.

Just be careful as always. I personally do a copy of the `long_term_memory.db` file to a separate folder first and rename it to `long_term_memory.cpy.db`. After that, I open the copy. I always let the original untouched. With the seconary file extension `cpy` (which means copy) I know exactly, I can't brake anything and I even can delete it later, because it is just a copy.

### Why exporting your memories from the SQLite DB actually makes no sense
This is a part of the readme, you should think about. All the memories in the DB are managed by the LTM and the sentence_model. The Zarr directory contains the vector informations where the the memory belongs to in the database and the sci-kit software can search for the best memory to load. If you rip this apart by separating the memory from the vectors, you just keep the information, but without the relation to each other and also just the remembered part. It is much better to save the complete json chat history to use it elsewhere, then to extract the memories to a csv file.

## Some potential alternatives: 
- (not merged) [langchain support in oobabooga](https://github.com/oobabooga/text-generation-webui/issues/665)
- (merged) [SuperBIG](https://github.com/oobabooga/text-generation-webui/pull/1548)

## Acknowledgements
- wawawario2 for creating this great extension
- Claudia Catfox for helping me testing this extension long-term and finding the right settings
- Sally TX for helping me testing the extension and finding bugs and weaknesses
- the little all-mpnet-base-v2 model for doing such a great job
- the people who created all-mpnet-base-v2
- Oobabooga for constantly inproving the main program text-generation-webui
- and all the great people, who have participated and helped to improve this extension and the main program

love Rangar / Sonic2k
