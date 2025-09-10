(use-package ekg
  :bind (([insert] . ekg-capture))
  :init
  (require 'ekg-embedding)
  (ekg-embedding-generate-on-save)
  (require 'ekg-llm)
  (require 'llm-openai)  ;; The specific provider you are using must be loaded.
  (let ((my-provider (make-llm-openai-compatible :url "https://openrouter.ai/api/v1" :key "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"
                                                 :chat-model ""
                                                 :embedding-model "")))
    (setq ekg-llm-provider my-provider
          ekg-embedding-provider my-provider)))
