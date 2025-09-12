import SwiftUI

struct FullScreenImageEditorView: View {
    @Binding var inputImage: UIImage?
    @Binding var processedImage: UIImage?
    @Binding var isPresented: Bool
    
    @State private var workingImage: UIImage?
    @State private var filterIntensity: Double = 0.5
    @State private var selectedFilterType: FilterType = .sepia
    
    private let filterProcessor = ImageFilterProcessor()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Image preview area
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    if let image = workingImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                    } else if let inputImage = inputImage {
                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.6)
                
                // Editor controls
                EditorControlsView(
                    inputImage: inputImage,
                    workingImage: $workingImage,
                    filterIntensity: $filterIntensity,
                    selectedFilterType: $selectedFilterType
                )
                .padding()
                .padding(.bottom, 60)
                .background(Color(.systemBackground))
            }
            .navigationTitle("Edit Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        processedImage = workingImage
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                // Initialize with current processed image or original input image
                workingImage = processedImage ?? inputImage
            }
        }
    }
}

struct EditorControlsView: View {
    let inputImage: UIImage?
    @Binding var workingImage: UIImage?
    @Binding var filterIntensity: Double
    @Binding var selectedFilterType: FilterType
    
    private let filterProcessor = ImageFilterProcessor()
    
    var body: some View {
        VStack(spacing: 20) {
            // Filter selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Filters")
                    .font(.headline)
                
                FilterGridView(
                    inputImage: inputImage,
                    selectedFilterType: $selectedFilterType,
                    onFilterSelected: { filterType in
                        selectedFilterType = filterType
                        filterIntensity = 0.5
                        applyCurrentFilter()
                    }
                )
            }
            
            // Intensity control - Always visible but disabled when not applicable
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Intensity: \(Int(filterIntensity * 100))%")
                        .font(.subheadline)
                        .foregroundColor(selectedFilterType.supportsIntensity ? .primary : .secondary)
                    
                    Spacer()
                    
                    if !selectedFilterType.supportsIntensity {
                        Text("Not adjustable")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Slider(value: $filterIntensity, in: 0...1, step: 0.01)
                    .disabled(!selectedFilterType.supportsIntensity)
                    .opacity(selectedFilterType.supportsIntensity ? 1.0 : 0.6)
                    .onChange(of: filterIntensity) { _, _ in
                        applyCurrentFilter()
                    }
            }
            
            // Action buttons
            HStack(spacing: 16) {
                Button("Revert to Original") {
                    revertToOriginal()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
        }
        .onChange(of: selectedFilterType) { _, _ in
            applyCurrentFilter()
        }
    }
    
    private func applyCurrentFilter() {
        guard let inputImage = inputImage else { return }
        
        let intensity = selectedFilterType.supportsIntensity ? filterIntensity : 1.0
        
        workingImage = filterProcessor.applyFilter(
            to: inputImage,
            filterType: selectedFilterType,
            intensity: intensity
        )
    }
    
    private func revertToOriginal() {
        workingImage = inputImage
        filterIntensity = 0.5
        selectedFilterType = .sepia // Reset to default filter
    }
}
