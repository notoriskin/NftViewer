//
//  ContentView.swift
//  NFT Viewer App
//
//  Created by Boris Ryavkin on 15/7/2025.
//

import SwiftUI

// MARK: - Alchemy NFT API Models
struct NFTResponse: Codable {
    let ownedNfts: [OwnedNFT]
}

struct OwnedNFT: Codable, Identifiable {
    // Use contract.address + tokenId as unique id
    var id: String { contract.address + tokenId }
    let contract: NFTContract
    let idData: NFTId
    let title: String?
    let metadata: Metadata?
    
    enum CodingKeys: String, CodingKey {
        case contract
        case idData = "id"
        case title
        case metadata
    }
    
    // For convenience, expose tokenId
    var tokenId: String { idData.tokenId }
}

struct NFTContract: Codable {
    let address: String
    let metadata: NFTContractMetadata?
}

struct NFTContractMetadata: Codable {
    let name: String?
}

struct NFTId: Codable {
    let tokenId: String
}

struct Metadata: Codable {
    let name: String?
    let image: String?
}

// MARK: - API Configuration
private let apiKey = "ehJiDcer78_aGMrHQPHECBMDCn1U-qiM"

private func buildNFTURL(for address: String) -> URL? {
    let baseURL = "https://eth-mainnet.g.alchemy.com/nft/v2/\(apiKey)/getNFTs"
    var components = URLComponents(string: baseURL)
    components?.queryItems = [
        URLQueryItem(name: "owner", value: address),
        URLQueryItem(name: "withMetadata", value: "true")
    ]
    return components?.url
}

// MARK: - View Model
@MainActor
class NFTViewModel: ObservableObject {
    @Published var nfts: [OwnedNFT] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var walletAddress = ""
    
    func fetchNFTs() async {
        guard !walletAddress.isEmpty else {
            errorMessage = "Please enter a wallet address"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = buildNFTURL(for: walletAddress) else {
            errorMessage = "Invalid wallet address"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "Failed to fetch NFTs"
                isLoading = false
                return
            }
            
            let nftResponse = try JSONDecoder().decode(NFTResponse.self, from: data)
            nfts = nftResponse.ownedNfts
            isLoading = false
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
            isLoading = false
        }
    }
}

// MARK: - IPFS Helper
func resolveImageURL(_ urlString: String?) -> URL? {
    guard let urlString = urlString else { return nil }
    if urlString.hasPrefix("ipfs://") {
        let hash = urlString.replacingOccurrences(of: "ipfs://", with: "")
        return URL(string: "https://ipfs.io/ipfs/\(hash)")
    } else {
        return URL(string: urlString)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = NFTViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 16) {
                    Text("NFT Viewer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Wallet Address Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Wallet Address")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            TextField("0x...", text: $viewModel.walletAddress)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            Button("Fetch") {
                                Task {
                                    await viewModel.fetchNFTs()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.walletAddress.isEmpty || viewModel.isLoading)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Content Area
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading NFTs...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else if viewModel.nfts.isEmpty && !viewModel.walletAddress.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No NFTs found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("This wallet doesn't contain any NFTs")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    // NFT Grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(viewModel.nfts) { nft in
                                NFTCard(nft: nft)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - NFT Card View
struct NFTCard: View {
    let nft: OwnedNFT
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // NFT Image
            if let url = resolveImageURL(nft.metadata?.image) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        )
                }
                .frame(height: 200)
                .clipped()
                .cornerRadius(12)
            } else {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    )
                    .cornerRadius(12)
            }
            
            // NFT Details
            VStack(alignment: .leading, spacing: 4) {
                Text(nft.metadata?.name ?? nft.title ?? "Unknown NFT")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(nft.contract.metadata?.name ?? "Unknown Collection")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ContentView()
}
