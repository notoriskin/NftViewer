# 🖼 NFT Viewer App

A clean, minimal iOS app built with SwiftUI that allows users to **view NFTs owned by any Ethereum wallet**, using the [Alchemy NFT API](https://www.alchemy.com/nft). Just paste your MetaMask wallet address and instantly browse your collection.
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-15 at 16 38 12" src="https://github.com/user-attachments/assets/141b387d-fb74-4397-9357-e1c0c12e4699" />

---

## 🚀 Features

- 🔍 Paste any **Ethereum wallet address**
- 🎲 Fetch all NFTs owned by that address using Alchemy’s API
- 🧾 Display:
  - NFT Image
  - Name
  - Collection name
- 📄 Handles metadata and `ipfs://` links
- 🧼 Elegant, responsive SwiftUI interface

---

## 🔧 Built With

- `SwiftUI` – UI Framework  
- `URLSession` – for async networking  
- `Alchemy NFT API` – wallet-to-NFT lookup  
- `AsyncImage` – image rendering  
- `Codable` – JSON decoding  
- `IPFS support` – URL resolver  
- `Dark mode` ready  
- `macOS-compatible` (multiplatform if extended)

---

## 🧑‍🏫 What is the point of this?
This project marked my first hands-on experience integrating a third-party API. I used Alchemy’s NFT API, and while the documentation was clear and comprehensive, I encountered a few initial challenges.

The first issue was receiving unexpected empty responses when querying wallet addresses — which I later realized was due to forgetting to enable the NFT API plugin in my Alchemy dashboard. Once I activated the correct service and double-checked my API key permissions, the endpoint started returning data correctly.

Another small obstacle was handling ipfs:// image links in the NFT metadata. Alchemy provides raw IPFS URIs, which aren’t directly compatible with AsyncImage in SwiftUI. I resolved this by writing a small utility function that converts IPFS links to HTTPS URLs via a public gateway (ipfs.io).

Overall, working through these issues gave me a much deeper understanding of how APIs are authenticated, how to handle decentralized media formats, and how to safely manage user input in a mobile app.

## 🤖If you need this app for some reason
2.	Open in Xcode 15+
	3.	Get a free API key from alchemy.com
	4.	Paste your key in ContentView.swift:
<pre lang="markdown"><code> ```swift
private let apiKey = "your-api-key-here"
  ```
</code></pre>
🧠 Future Ideas
build an app that will handle the owned nft's a stickers emeded in text similar to how notion has its icons on per page basis 

👨‍💻 Author

Built by Boris Ryavkin
🧠 Inspired by curiosity + simplicity
💼 Designed for portfolio visibility and iOS developer growth

⸻

📄 License

MIT License

