import UIKit
import QuickLook

class DocumentTableViewController: UITableViewController, QLPreviewControllerDataSource, UIDocumentPickerDelegate {

    enum DocumentSource {
        case imported
        case bundle
    }
    
    struct DocumentFile {
        var title: String
        var size: Int
        var imageName: String?
        var url: URL
        var type: String
        var source: DocumentSource
    }
    
    var fileToPreview: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDocument))
    }
    
    
    // MARK: - Add Document
    
    @objc func addDocument() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.jpeg, .png, .pdf, .text])
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .overFullScreen
        present(documentPicker, animated: true)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        dismiss(animated: true)
        guard url.startAccessingSecurityScopedResource() else {
            return
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        copyFileToDocumentsDirectory(fromUrl: url)
    }
    
    // Copy and Reload
    func copyFileToDocumentsDirectory(fromUrl url: URL) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectory.appendingPathComponent(url.lastPathComponent)
        
        do {
            try FileManager.default.copyItem(at: url, to: destinationUrl)
            self.tableView.reloadData()
        } catch {
            print("Error copying file: \(error)")
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let documents = listFileInDocumentsDirectory()
        let filteredDocuments: [DocumentFile]
        
        switch section {
        case 0:
            filteredDocuments = documents.filter { $0.source == .imported }
        case 1:
            filteredDocuments = documents.filter { $0.source == .bundle }
        default:
            filteredDocuments = []
        }
        
        return filteredDocuments.count
    }
    
    // Section Header Titles
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Imported Documents"
        case 1:
            return "Bundle Documents"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let documents = listFileInDocumentsDirectory()
        let filteredDocuments: [DocumentFile]
        
        switch indexPath.section {
        case 0:
            filteredDocuments = documents.filter { $0.source == .imported }
        case 1:
            filteredDocuments = documents.filter { $0.source == .bundle }
        default:
            filteredDocuments = []
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
        let document = filteredDocuments[indexPath.row]
        
        cell.textLabel?.text = document.title
        cell.detailTextLabel?.text = document.size.formattedSize()
        
        return cell
    }
    
    // MARK: - QLPreviewController

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let fileToPreview = fileToPreview else {
            fatalError("File URL not set for preview.")
        }
        return fileToPreview as QLPreviewItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let documents = listFileInDocumentsDirectory()
        let filteredDocuments: [DocumentFile]
        
        switch indexPath.section {
        case 0:
            filteredDocuments = documents.filter { $0.source == .imported }
        case 1:
            filteredDocuments = documents.filter { $0.source == .bundle }
        default:
            filteredDocuments = []
        }
        
        let selectedDocument = filteredDocuments[indexPath.row]
        instantiateQLPreviewController(withUrl: selectedDocument.url)
    }
    
    func instantiateQLPreviewController(withUrl url: URL) {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        fileToPreview = url
        self.navigationController?.pushViewController(previewController, animated: true)
    }
    
    // MARK: - Helper functions

    // Returns the list of files in the Documents directory and bundled files
    func listFileInDocumentsDirectory() -> [DocumentFile] {
        let fm = FileManager.default
        let documentsDirectory = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let items = try! fm.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: [.nameKey, .fileSizeKey], options: .skipsHiddenFiles)
        
        var documentList = [DocumentFile]()
        
        for item in items {
            let resourcesValues = try! item.resourceValues(forKeys: [.nameKey, .fileSizeKey])
            
            if item.hasDirectoryPath { continue }
            
            documentList.append(DocumentFile(
                title: resourcesValues.name!,
                size: resourcesValues.fileSize ?? 0,
                imageName: item.lastPathComponent,
                url: item,
                type: "application/octet-stream",
                source: .imported
            ))
        }
        documentList.append(contentsOf: listFileInBundle())
        
        return documentList
    }
    
    // MARK: - Bundle Images
    
    func listFileInBundle() -> [DocumentFile] {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)

        var documentListBundle = [DocumentFile]()
        
        for item in items {
            if !item.hasSuffix("DS_Store") && item.hasSuffix(".jpeg") {
                let currentUrl = URL(fileURLWithPath: path + "/" + item)
                let resourcesValues = try! currentUrl.resourceValues(forKeys: [.contentTypeKey, .nameKey, .fileSizeKey])

                documentListBundle.append(DocumentFile(
                    title: resourcesValues.name!,
                    size: resourcesValues.fileSize ?? 0,
                    imageName: item,
                    url: currentUrl,
                    type: resourcesValues.contentType!.description,
                    source: .bundle
                ))
            }
        }
        return documentListBundle
    }
}

extension Int {
    func formattedSize() -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(self))
    }
}
