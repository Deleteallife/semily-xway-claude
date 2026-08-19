# Safety and image delivery

## Always deliver the images

Call `creative_set_result`, then `creative_variant_result` separately for V1–V5.

Delivery in Claude Code works like this:

1. Download all five approved artifacts into one task-specific local folder, for example `.semily/<cycle>/` under the working directory, or the session scratchpad when one is provided.
2. Verify each file is non-zero and a valid image.
3. Open each file with the `Read` tool so you actually see the artwork before you present it. This is the QA gate — do it for all five.
4. Present them to the user, best available surface first:
   - a file-attachment tool such as `SendUserFile`, when this session has one — send all five in one call;
   - otherwise write a single local HTML contact sheet that embeds the five images with their labels, publish it with `Artifact` if that tool exists, and give the user the link;
   - otherwise list the five absolute local paths as Markdown image tags plus clickable file links, and say explicitly that the files are on disk at those paths.

A remote Markdown URL, a filename, a placeholder, or a tool status card alone does not count as delivery. Do not finish with broken image placeholders.

Present each image under its label (V1–V5) and a one-line hypothesis.

## Writes

Before launch or applying a winner, require persisted authorization and server idempotency. Reverse-check every XWAY write. If a write times out with an unknown outcome, inspect current state before retrying — never blind-retry a state-changing call.

Never expose OAuth tokens, refresh tokens, CSRF values, database credentials, or browser sessions, and never ask the user to paste them into chat. Authentication belongs in `/mcp`, not in the conversation.
