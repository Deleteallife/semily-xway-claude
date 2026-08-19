# WB analysis

Read this file before hypotheses or generation.

## Evidence collection

1. Call `prepare_wb_analysis` with the SKU and optional `cycle_uuid`.
2. Open its `search_url`; preserve the selected query. Use whichever web capability this session actually has: the browser tools when they are available, otherwise `WebFetch`. The WB search page is a SPA, so the JSON catalogue response it loads is usually more reliable to read than the rendered HTML. If no web capability is available, say so instead of inventing cards.
3. Inspect organic results from the top. Exclude ads, sponsored shelves, the target SKU, and unrelated cards.
4. Record the first 20 unique relevant organic products. Fail closed if fewer than 20 can be verified.
5. For each relevant card record: SKU, organic position, image URL, background family, product scale and position, negative space, contrast, prop count/location, text layout, pill/badge layout, angle, safe-area conflicts, thumbnail readability, and saliency separation.
6. Separate observation from inference. Inference has one mechanism, `low` or `medium` confidence, exact observed basis fields, and a caveat that competitor patterns do not prove or guarantee CTR.
7. Call `record_wb_analysis`. Continue only when it returns `state: analysis_recorded` and `analysis_uuid`.

## Designer/marketing synthesis

Summarize repeated background constructions, dominant object placement, thumbnail legibility, text hierarchy, badges, contrast, and category conventions. Turn these into testable levers, not aesthetic opinions. Do not cherry-pick attractive cards or attach revenue, orders, or margin to comparator images.
