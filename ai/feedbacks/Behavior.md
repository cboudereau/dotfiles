# Different Behavior on same model
This is a great skill. The hallucination difference between Copilot and Cursor using the same underlying model comes down to several factors:
  1. System prompt and tool orchestration
  Even with the same model (e.g., Claude), each tool wraps it differently. Cursor's agent has a detailed system prompt that instructs it to use tools
  (Read, Grep, Glob, etc.) before making claims. Copilot CLI has a different system prompt with different tool-calling conventions. The model behaves
  differently depending on what it's told it can do and how it's told to do it.
  2. Tool availability and design
  Cursor gives the model granular file tools (Read, Grep, SemanticSearch, Glob) that naturally encourage a "look before you speak" workflow. If Copilot
  CLI exposes fewer or coarser tools, the model is more likely to reason from memory instead of verifying against the codebase. A model that can't
  easily search will guess instead.
  3. Context window management
  How each tool manages context matters a lot. Cursor progressively loads files on demand, keeping context fresh and relevant. If Copilot front-loads a
  large chunk of context or truncates it differently, the model may fill gaps with plausible-sounding but incorrect information — classic hallucination.
  4. Agentic loop behavior
  Cursor runs a multi-step agent loop: the model can call a tool, read the result, then decide what to do next. The number of iterations, how tool
  results are fed back, and when the model is asked to produce a final answer all influence accuracy. A shorter loop or fewer tool calls means less
  verification.
  5. Temperature and sampling
  Each product may use different temperature/sampling settings for the same model. Lower temperature = more deterministic and grounded. Higher
  temperature = more creative but more prone to fabrication.
  So even with the identical model weights, the "shell" around it (system prompt, tools, context management, sampling) fundamentally changes behavior.
  Your evidence-based-analysis skill is essentially compensating for Copilot's weaker grounding loop by explicitly instructing the model to self-verify
  — something Cursor's agent architecture partially enforces by design.
  That said, no setup is immune — you may eventually hit hallucinations in Cursor too, especially on tasks where the model doesn't use tools
  proactively. The skill is still valuable as a portable safeguard across any tool.