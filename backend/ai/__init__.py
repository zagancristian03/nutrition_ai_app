"""AI coaching layer.

Public surface:
    * `openai_client.chat_completion` — thin OpenAI wrapper
    * `context`                        — builds compact coaching context
    * `prompts`                        — system prompt templates
    * `memory`                         — message window + summarization
    * `services`                       — DB-facing orchestration used by the router
"""
