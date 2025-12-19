;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2025 Manus AI <manus@optimizer.ai>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.

(define-module (test-agi-os-engine)
  #:use-module (guix agi-os-engine)
  #:use-module (guix cognitive-kernel)
  #:use-module (srfi srfi-64))

;;;
;;; Test suite for AGI-OS Engine
;;;

(test-begin "agi-os-engine")

;;; Configuration Tests

(test-assert "default config creation"
  (agi-os-config? %default-agi-os-config))

(test-equal "default autonomous mode"
  #t
  (agi-os-config-autonomous-mode %default-agi-os-config))

(test-equal "default learning rate"
  0.1
  (agi-os-config-learning-rate %default-agi-os-config))

(test-equal "default optimization level"
  'balanced
  (agi-os-config-optimization-level %default-agi-os-config))

;;; Engine Tests

(test-assert "engine creation"
  (let ((engine (make-agi-os-engine)))
    (agi-os-engine? engine)))

(test-equal "engine initial state"
  'initialized
  (let ((engine (make-agi-os-engine)))
    (agi-os-engine-state engine)))

(test-assert "engine start"
  (let* ((engine (make-agi-os-engine))
         (started (agi-os-engine-start engine)))
    (eq? (agi-os-engine-state started) 'running)))

(test-assert "engine stop"
  (let* ((engine (make-agi-os-engine))
         (started (agi-os-engine-start engine))
         (stopped (agi-os-engine-stop started)))
    (eq? (agi-os-engine-state stopped) 'stopped)))

;;; Decision Making Tests

(test-assert "cognitive decision creation"
  (let ((decision (cognitive-decision
                   (action 'update-package)
                   (confidence 0.85)
                   (reasoning "Test reasoning"))))
    (cognitive-decision? decision)))

(test-equal "decision action"
  'update-package
  (let ((decision (cognitive-decision
                   (action 'update-package)
                   (confidence 0.85)
                   (reasoning "Test"))))
    (cognitive-decision-action decision)))

(test-assert "engine decide"
  (let* ((engine (make-agi-os-engine))
         (decision (agi-os-engine-decide engine 'package-update)))
    (cognitive-decision? decision)))

(test-assert "decision confidence in range"
  (let* ((engine (make-agi-os-engine))
         (decision (agi-os-engine-decide engine 'package-update))
         (conf (cognitive-decision-confidence decision)))
    (and (>= conf 0.0) (<= conf 1.0))))

;;; Optimization Tests

(test-assert "engine optimize"
  (let* ((engine (make-agi-os-engine))
         (result (agi-os-engine-optimize engine 'test-target)))
    (list? result)))

;;; Learning Tests

(test-assert "engine learn"
  (let ((engine (make-agi-os-engine)))
    (agi-os-engine-learn engine '(test-experience)
                         #:feedback 'positive)
    #t))

;;; Knowledge Base Tests

(test-assert "knowledge base exists"
  (let ((engine (make-agi-os-engine)))
    (hash-table? (agi-os-engine-knowledge-base engine))))

(test-assert "knowledge base tracks decisions"
  (let* ((engine (make-agi-os-engine))
         (kb (agi-os-engine-knowledge-base engine))
         (_ (agi-os-engine-decide engine 'test))
         (count (hash-ref kb 'decision-count)))
    (> count 0)))

;;; Cognitive Kernel Tests

(test-assert "cognitive kernel creation"
  (let ((kernel (make-cognitive-kernel)))
    (cognitive-kernel? kernel)))

(test-equal "kernel initial state"
  'initialized
  (let ((kernel (make-cognitive-kernel)))
    (cognitive-kernel-status kernel)))

(test-assert "kernel init"
  (let* ((kernel (make-cognitive-kernel))
         (initialized (cognitive-kernel-init kernel)))
    (eq? (cognitive-kernel-status initialized) 'running)))

;;; AtomSpace Tests

(test-assert "cognitive atom creation"
  (let ((atom (cognitive-atom
               (type 'ConceptNode)
               (name "test")
               (tv '(1.0 1.0)))))
    (cognitive-atom? atom)))

(test-equal "atom type"
  'ConceptNode
  (let ((atom (cognitive-atom
               (type 'ConceptNode)
               (name "test"))))
    (cognitive-atom-type atom)))

;;; PLN Tests

(test-assert "pln inference creation"
  (let ((inference (pln-inference
                    (query "test-query")
                    (max-steps 5))))
    (pln-inference? inference)))

(test-assert "pln inference result"
  (let* ((kernel (make-cognitive-kernel))
         (inference (pln-inference
                     (query "test")
                     (max-steps 5)))
         (result (cognitive-kernel-reason kernel inference)))
    (pln-inference-result? result)))

;;; ECAN Tests

(test-assert "attention value creation"
  (let ((av (ecan-attention-value
             (sti 100)
             (lti 50))))
    (ecan-attention-value? av)))

(test-equal "attention sti"
  100
  (let ((av (ecan-attention-value
             (sti 100)
             (lti 50))))
    (ecan-attention-value-sti av)))

(test-end "agi-os-engine")
