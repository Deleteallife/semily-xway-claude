---
name: semily-xway-studio
description: Use when a user asks to analyze WB (Wildberries) competitors, create five marketplace covers from product/reference images, launch or monitor an XWAY image test, apply a statistically confirmed winner, or continue a winner-driven creative improvement cycle. Also triggers on "артикул", "обложки", "XWAY", "A/B тест обложек", "CTR карточки".
---

# Semily XWAY Studio

## Principle

Run one evidence-driven chain: WB analysis → five controlled covers → visible delivery → one approval → XWAY test → CTR decision → verified winner → next cycle. Use the hosted `semily_xway` MCP tools for live data and writes. Never claim a server action succeeded without tool evidence.

## Tools

Every server tool is exposed by Claude Code under the `mcp__semily_xway__` prefix. Throughout this skill a bare name such as `prepare_wb_analysis` means `mcp__semily_xway__prepare_wb_analysis`.

- If those tools are not in your tool list, they may be deferred behind tool search. Load them in one call, for example `ToolSearch` with `select:mcp__semily_xway__prepare_wb_analysis,mcp__semily_xway__record_wb_analysis,mcp__semily_xway__confirm_hypotheses_and_start_generation,mcp__semily_xway__creative_set_status`, or search `+semily xway`.
- If the server is not configured at all, tell the user to install the plugin and connect: `/plugin install semily-xway-studio@semily`, then `/mcp` → `semily_xway` → Authenticate.
- If a call fails with an authentication or `invalid_token` error, the OAuth session expired. Tell the user to re-authenticate with `/mcp` (or `claude mcp login semily_xway`). Preserve cycle state and pause; do not create a duplicate monitor or test.
- Never request passwords, tokens, cookies, browser profiles, or database credentials in chat, and never print OAuth tokens, refresh tokens, CSRF values, or database credentials.

## Start

1. Require WB article/SKU and a product image. Accept a background/design reference when supplied.
2. Call `start_semily_test` immediately when attachments are present. Pass a third text/layout creative as `layout_reference`. Default to `openai/gpt-image-2` through Provod unless the user names another supported model.
3. Ask only for a missing SKU, a missing required product image, or genuinely uncertain critical product text. Never ask the user to write an internal prompt.
4. If `semily_xway` is unavailable, prepare analysis and hypotheses only, and state plainly that launch, monitoring, and winner application are unavailable.

## Full workflow

1. Read [WB analysis](references/wb-analysis.md). Call `prepare_wb_analysis`, inspect the first 20 relevant organic WB cards, and persist them with `record_wb_analysis`. Do not generate before receiving `analysis_uuid`.
2. Read [creative generation](references/creative-generation.md). Build exactly five non-random hypotheses V1–V5 from observed WB patterns, prior cycle learning, and the current champion.
3. Generate all five via `confirm_hypotheses_and_start_generation` with `confirmed_texts=[]`. Poll `creative_set_status` in the same turn; do not schedule a background monitor for generation and do not ask the user to check later.
4. When reusable copy came from `layout_reference`, call `bind_layout_reference_copy` with transcribed blocks and forbidden promo/UI text; omit `source_sha256` so the server binds the persisted layout file. Do this before delivery and without another Provod call.
5. Inspect and QA all outputs. Retry only failed variants. Call `creative_set_result`, then call `creative_variant_result` separately for V1, V2, V3, V4, and V5.
6. Read [delivery and safety](references/safety-and-delivery.md). Deliver five actual images to the user. A filename, tool preview, or remote URL alone is not delivery.
7. After all five are delivered, request one approval. Accept an unambiguous `ОК`, `OK`, `да`, `подтверждаю`, `утверждаю`, `одобряю`, or `запускай`. A correction request is not approval.
8. On approval, call `approve_completed_creatives_for_xway`, follow `next_action_tool`, and continue without asking for a second launch confirmation.
9. Read [XWAY experiments](references/xway-experiments.md). Launch champion + V1–V5, monitor at roughly hourly intervals, apply only a qualified winner, and verify the main-image read-back.
10. After a winner, start the next cycle from that champion and create five new evidence-based challengers. Strengthen the winning mechanism; do not reset to random covers or repeat a proven loser.

## Non-negotiable rules

- Use text only when it is visibly verified on the supplied product/reference image or explicitly authorized product data. Промокод не копировать. Never invent a claim.
- Preserve product count, proportions, geometry, colors, logo, label artwork, and readable package text.
- Keep the current champion unchanged as control.
- CTR from XWAY is the primary decision metric. Выручка на 1 000 показов — не использовать, because it cannot be attributed reliably to the image active at that time.
- State-changing calls require server idempotency and reverse verification.
- One approval gates the launch. Never launch, stop, or overwrite an XWAY test without it.

## Completion

For generation, complete only after five covers are actually delivered to the user. For launch, complete only after the XWAY read-back confirms six frames. For winner application, complete only after the main-image read-back matches the winning artifact.
