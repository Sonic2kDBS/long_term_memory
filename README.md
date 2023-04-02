# Text Generation Web UI with Long-Term Memory
NOTICE: If you have been using this extension on or before 04/01/2023, you should follow the [migration instructions](#migration-instructions).

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

## Tips for Windows Users (credit to Anons from /g/'s /lmg/)
- The LTM's extensions's dependencies may override the version of pytorch needed to run your LLMs. If this is the case, try reinstalling the original version of pytorch manually:
```bash
pip install torch-1.12.0+cu113 # or whichever version of pytorch was uninstalled
```

## Features
- Memories are fetched using a semantic search, which understands the "actual meaning" of the messages.
- Ability to load an arbitrary number of "memories".
- Other configuration options, see below.

## Limitations
- There's one universal LTM database, so it's recommended to stick with just one character. If you don't, all characters will see the memories of others. This will be addressed soon.
- Each memory sticks around for one message.
- Memories themselves are past raw conversations filtered solely on length, and some may be irrelevant or filler text.
- Limited scalability: Appending to the persistent LTM database is reasonably efficient, but we currently load all LTM embeddings in RAM, which consumes memory. Additionally, we perform a linear search across all embeddings during each chat round.

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

## Migration Instructions 
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
