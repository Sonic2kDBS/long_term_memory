# Text Generation Web UI with Long-Term Memory

NOTICE: [This extension is no longer in active development.](#exporting-your-memories)

NOTICE TO WINDOWS USERS: If you have a space in your username, you may have [problems with this extension](https://github.com/wawawario2/long_term_memory/issues/39). 

NOTICE: This extension may conflict with [other extensions that modify the context](https://github.com/wawawario2/long_term_memory/issues/44)

NOTICE: If you have been using this extension on or before 05/06/2023, you should follow the [character namespace migration instructions](#character-namespace-migration-instructions).

NOTICE: If you have been using this extension on or before 04/01/2023, you should follow the [extension migration instructions](#extension-migration-instructions).

Welcome to the experimental repository for the long-term memory (LTM) extension for oobabooga's Text Generation Web UI. The goal of the LTM extension is to enable the chatbot to "remember" conversations long-term. Please note that this is an early-stage experimental project, and perfect results should not be expected. This project has been tested on Ubuntu LTS 22.04. Other people have tested it successfully on Windows. Compatibility with macOS is unknown.

## How to Run
1. Clone [oobabooga's  original repository](https://github.com/oobabooga/text-generation-webui) and follow the instructions until you can chat with a chatbot.

2. Make sure you're in the `text-generation-webui` directory and clone this repository directly into the `extensions` directory
```bash
git clone https://github.com/wawawario2/long_term_memory extensions/long_term_memory
```
3. Within the `textgen` conda environment (from the linked instructions), run the following commands to install dependencies and run tests:
```bash
pip install -r extensions/long_term_memory/requirements.txt
python -m pytest -v extensions/long_term_memory/
```
4. Run the server with the LTM extension. If all goes well, you should see it reporting "ok"
```bash
python server.py --chat --extensions long_term_memory
```
5. Chat normally with the chatbot and observe the console for LTM write/load status. Please note that LTM-stored memories will only be visible to the chatbot during your NEXT session, though this behavior can be overridden via the UI. Additionally please use the same name for yourself across sessions, otherwise the chatbot may get confused when trying to understand memories (example: if you have used "anon" as your name in the past, don't use "Anon" in the future)

6. Memories will be saved in `extensions/long_term_memory/user_data/bot_memories/`. Back them up if you plan to mess with the code. If you want to fully reset your bot's memories, simply delete the files inside that directory.

## Tips for Windows Users (credit to Anons from /g/'s /lmg/ and various people on github)
This extension can be finnicky on Windows machines. Some general tips:
- The LTM's extensions's dependencies may override the version of pytorch needed to run your LLMs. If this is the case, try reinstalling the original version of pytorch manually:
```bash
pip install torch-1.12.0+cu113 # or whichever version of pytorch was uninstalled
```
Other relevant discussions
- [Missing dependencies](https://github.com/wawawario2/long_term_memory/discussions/23)
- [Spaces in Windows usernames](https://github.com/wawawario2/long_term_memory/issues/39)

## Features
- Memories are fetched using a semantic search, which understands the "actual meaning" of the messages.
- Separate memories for different characters, all handled under the hood for you. (legacy users see [character namespace migration instructions](#character-namespace-migration-instructions).)
- Ability to load an arbitrary number of "memories".
- Other configuration options, see below.

## Limitations
- Each memory sticks around for one message.
- Memories themselves are past raw conversations filtered solely on length, and some may be irrelevant or filler text.
- Limited scalability: Appending to the persistent LTM database is reasonably efficient, but we currently load all LTM embeddings in RAM, which consumes memory. Additionally, we perform a linear search across all embeddings during each chat round.
- Only operates in chat mode. This also means that as of this writing this extension doesn't work with the API

## How the Chatbot Sees the LTM
Chatbots are typically given a fixed, "context" text block that persists across the entire chat. The LTM extension augments this context block by dynamically injecting a relevant long-term memory.

### Example of a typical context block:
```markdown
The following is a conversation between Anon and Miku. Miku likes Anon but is very shy.
```

### Example of an augmented context block:
```markdown
Miku's memory log:
3 days ago, Miku said:
"So Anon, your favorite color is blue? That's really cool!"

During conversations between Anon and Miku, Miku will try to remember the memory described above and naturally integrate it with the conversation.
The following is a conversation between Anon and Miku. Miku likes Anon but is very shy.
```

## Configuration
You can configure the behavior of the LTM extension by modifying the `ltm_config.json` file. The following is a typical example:
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
### `ltm_context.injection_location`
One of two values, `BEFORE_NORMAL_CONTEXT` or `AFTER_NORMAL_CONTEXT_BUT_BEFORE_MESSAGES`. They behave as written on the tin.
If you use `AFTER_NORMAL_CONTEXT_BUT_BEFORE_MESSAGES`, within the `context` field of your character config, you must add a `<START>` token AFTER the character description and BEFORE the example conversation. See [the following example](https://github.com/wawawario2/long_term_memory/blob/master/example_character_configs/Example_with_START_token.yaml).

### `ltm_context.memory_context_template`
This defines the sub-context that's injected into the original context. Note the embedded params surrounded by `{}`, the system will automatically fill these in for you based on the memory it fetches, you don't actually fill the values in yourself here. You also don't have to place all of these params, just place what you need:
- `{name1}` is the current user's name
- `{name2}` is the current bot's name
- `{all_memories}` is the concatenated list of ALL relevant memories fetched by LTM 

### `ltm_context.memory_template`
This defines an individual memory's format. Similar rules apply.
- `{memory_name}` is the name of the entity that said the `{memory_message}`, which doesn't have to be `{name1}` or `{name2}`
- `{memory_message}` is the actual memory message
- `{time_difference}` is how long ago the memory was made (example: "4 days ago")

### `ltm_writes.min_message_length`
How long a message must be for it to be considered for LTM storage. Lower this value to allow "shorter" memories to get recorded by LTM.

### `ltm_reads.max_cosine_distance`
Controls how "similar" your last message has to be to the "best" LTM message to be loaded into the context. It represents the cosine distance, where "lower" means "more similar". Lower this value to reduce how often memories get loaded into the bot.

### `ltm_reads.num_memories_to_fetch`
The (maximum) number of memories to fetch from LTM. Raise this number to fetch more (relevant) memories, however, this will consume more of your fixed context budget.

### `ltm_reads.memory_length_cutoff_in_chars`
A hard cutoff for each memory's length. This prevents very long memories from flooding and consuming the full context.

## How It Works Behind the Scenes
### Database
- [zarr](https://zarr.readthedocs.io/en/stable/) is used to store embedding vectors on disk.
- [SQLite](https://www.sqlite.org/index.html) is used to store the actual memory text and additional attributes.
- [numpy](https://numpy.org/) is used to load the embedding vectors into RAM.

### Semantic Search
- Embeddings are generated using an SBERT model with the [SentenceTransformers](https://www.sbert.net/) library, specifically [sentence-transformers/all-mpnet-base-v2](https://huggingface.co/sentence-transformers/all-mpnet-base-v2).
- We use [scikit-learn](https://scikit-learn.org/) to perform a linear search against the loaded embedding vectors to find the single closest LTM given the user's input text.

## How You Can Help
- We need assistance with prompt engineering experimentation. How should we formulate the LTM injection?
- Test the system and try to break it, report any bugs you find.

## Roadmap
The roadmap will be driven based on user feedback. Potential updates include:

### New Features
- N-gram analysis for "higher quality memories".
- Scaling up memory bank size (with a limit of, perhaps, 4).

### Quality of Life Improvements
- Limit the size of each memory so it doesn't overwhelm the context.
- Other simple hacks to improve the end user-experience.

### Longer-Term (depending on interest/level of use)
- Integrate the system with [llama.cpp](https://github.com/ggerganov/llama.cpp).
- Merge the extension with oobabooga's original repo (depending on performance, level of interest, etc)
- Use a Large Language Model (LLM) to summarize raw text into more useful memories directly. This may be challenging just as an oobabooga extension.
- Scaling the backend.

## Character Namespace Migration Instructions 
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

## Extension Migration Instructions 
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

Some potential alternatives: 
- (not merged) [langchain support in oobabooga](https://github.com/oobabooga/text-generation-webui/issues/665)
- (merged) [SuperBIG](https://github.com/oobabooga/text-generation-webui/pull/1548)
