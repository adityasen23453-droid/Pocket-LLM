import urllib.request
import json
import sys

def test_query(msg, history=None):
    payload = {
        "message": msg,
        "use_rag": True,
        "top_k": 5,
        "active_document": "Assignment_8__Theory_and_Practice_of_Modern_Cryptography_.pdf",
        "chat_history": history
    }
    req = urllib.request.Request(
        "http://127.0.0.1:8000/api/chat",
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"}
    )
    tokens = []
    sources = []
    with urllib.request.urlopen(req, timeout=60) as resp:
        for line in resp:
            line_str = line.decode("utf-8").strip()
            if line_str.startswith("data: "):
                data = json.loads(line_str[6:])
                if data.get("type") == "sources":
                    sources = data["sources"]
                elif data.get("type") == "token":
                    tokens.append(data["content"])
                elif data.get("type") == "done":
                    break
    res = "".join(tokens)
    print(f"Received {len(tokens)} tokens.")
    sys.stdout.flush()
    return res, sources


print("[Test 1] Sending: All 10 questions of assignment 8 cryptography pdf")
ans1, sources1 = test_query("All 10 questions of assignment 8 cryptography pdf")
print(f"Sources: {sources1}")
print("Response 1:")
print("-" * 50)
print(ans1)
print("-" * 50)

print("\n[Test 2] Sending follow-up: What about other answers")
hist = [
    {"role": "user", "content": "All 10 questions of assignment 8 cryptography pdf"},
    {"role": "assistant", "content": ans1}
]
ans2, sources2 = test_query("What about other answers", hist)
print(f"Sources: {sources2}")
print("Response 2:")
print("-" * 50)
print(ans2)
print("-" * 50)
