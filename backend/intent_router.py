import os
import re
from enum import Enum
from typing import Tuple, Optional, List, Dict, Any

class QueryIntent(str, Enum):
    CONVERSATIONAL = "conversational"
    DOCUMENT_SUMMARY = "summary"
    ALL_QUESTIONS = "all_questions"
    CONTINUATION = "continuation"
    SPECIFIC_QA = "specific_qa"

# Exact regex patterns for zero-shot classification
GREETING_PATTERN = re.compile(
    r'^(hello|hi|hey|greetings|help\s*me|help|who\s*are\s*you|what\s*can\s*you\s*do|good\s*(morning|afternoon|evening)|thanks|thank\s*you)[\s!\.\?]*$',
    re.IGNORECASE
)

SUMMARY_PATTERN = re.compile(
    r'\b(summarize|summerize|summary|overview|brief|gist|main\s*points|what\s*is\s*this\s*(document|pdf)|explain\s*(the\s*)?(whole|entire|complete)?\s*(pdf|notes|document))\b',
    re.IGNORECASE
)

ALL_QUESTIONS_PATTERN = re.compile(
    r'\b(all\s*(\d+|the)?\s*questions?|solve\s*(all|the\s*entire|every|the\s*whole)?\s*(assignment|quiz|paper|pdf)|all\s*answers?|solutions?\s*to\s*all|solve\s*each\s*question|question\s*1\s*to\s*\d+)\b',
    re.IGNORECASE
)

CONTINUATION_PATTERN = re.compile(
    r'\b(what\s*about\s*(the\s*)?other\s*answers?|next\s*questions?|remaining\s*questions?|continue|solve\s*the\s*rest|other\s*answers?|remaining|next)\b',
    re.IGNORECASE
)

def classify_intent(query: str, has_active_document: bool) -> QueryIntent:
    """
    Classifies user intent with strict precedence to prevent context contamination.
    
    Precedence:
    1. Conversational greetings NEVER receive document context even if a document is loaded.
    2. All-questions full assignment solving requests.
    3. Conversational continuation requests.
    4. Summary / overview requests (including typos like 'summerize').
    5. Specific QA if document is available, otherwise Conversational.
    """
    q = (query or "").strip()
    if not q:
        return QueryIntent.CONVERSATIONAL
    
    # 1. Pure conversational queries NEVER use RAG
    if GREETING_PATTERN.match(q):
        return QueryIntent.CONVERSATIONAL
        
    # 2. Multi-question full assignment requests
    if ALL_QUESTIONS_PATTERN.search(q):
        return QueryIntent.ALL_QUESTIONS
        
    # 3. Conversational continuation / remaining questions
    if CONTINUATION_PATTERN.search(q):
        return QueryIntent.CONTINUATION
        
    # 4. Summary / overview requests
    if SUMMARY_PATTERN.search(q):
        return QueryIntent.DOCUMENT_SUMMARY
        
    # 5. Default: Specific QA if document is available, otherwise Conversational
    return QueryIntent.SPECIFIC_QA if has_active_document else QueryIntent.CONVERSATIONAL


def expand_conversational_query(
    query: str,
    active_document: Optional[str],
    chat_history: Optional[List[Dict[str, str]]] = None
) -> Tuple[str, Optional[str]]:
    """
    Expands ambiguous follow-up queries (e.g., 'What about other answers?', 'next')
    into explicit document-grounded search instructions while preserving active document context.
    """
    intent = classify_intent(query, has_active_document=bool(active_document))
    
    if intent == QueryIntent.CONTINUATION and active_document:
        doc_label = os.path.splitext(os.path.basename(active_document))[0].replace("_", " ")
        expanded = f"Solve the remaining questions from {doc_label} that were not answered in the previous response."
        return expanded, active_document
        
    return query, active_document

