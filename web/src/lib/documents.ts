/**
 * Documentation metadata and structure
 * Maps all available documentation files with metadata for the UI
 */

export interface Document {
  id: string
  title: string
  description: string
  category: 'guide' | 'reference' | 'api' | 'troubleshooting'
  path: string
  readingTime: string
  lines: number
}

export const documents: Record<string, Document> = {
  'readme': {
    id: 'readme',
    title: 'README',
    description: 'Complete overview of the SPLANTS Marketing Engine',
    category: 'guide',
    path: '/src/assets/documents/README_(1).md',
    readingTime: '15 min',
    lines: 850
  },
  'setup-guide': {
    id: 'setup-guide',
    title: 'Setup Guide',
    description: 'Step-by-step installation and configuration guide',
    category: 'guide',
    path: '/src/assets/documents/SETUP_GUIDE.md',
    readingTime: '12 min',
    lines: 700
  },
  'quickstart-windows': {
    id: 'quickstart-windows',
    title: 'Windows Quick Start',
    description: 'Quick setup guide specifically for Windows users',
    category: 'guide',
    path: '/src/assets/documents/QUICKSTART_WINDOWS.md',
    readingTime: '8 min',
    lines: 400
  },
  'troubleshooting': {
    id: 'troubleshooting',
    title: 'Troubleshooting',
    description: 'Common problems and solutions',
    category: 'troubleshooting',
    path: '/src/assets/documents/TROUBLESHOOTING.md',
    readingTime: '10 min',
    lines: 600
  },
  'faq': {
    id: 'faq',
    title: 'FAQ',
    description: 'Frequently asked questions and answers',
    category: 'reference',
    path: '/src/assets/documents/FAQ.md',
    readingTime: '20 min',
    lines: 1200
  },
  'api-guide': {
    id: 'api-guide',
    title: 'API Guide',
    description: 'Complete API reference and examples',
    category: 'api',
    path: '/src/assets/documents/docs_API_GUIDE_(1).md',
    readingTime: '6 min',
    lines: 300
  },
  'deployment': {
    id: 'deployment',
    title: 'Deployment Guide',
    description: 'Production deployment instructions',
    category: 'guide',
    path: '/src/assets/documents/docs_DEPLOYMENT_(1).md',
    readingTime: '7 min',
    lines: 350
  },
  'documentation-index': {
    id: 'documentation-index',
    title: 'Documentation Index',
    description: 'Complete index of all documentation',
    category: 'reference',
    path: '/src/assets/documents/DOCUMENTATION_INDEX.md',
    readingTime: '5 min',
    lines: 250
  }
}

// Helper function to get documents by category
export function getDocumentsByCategory(category: Document['category']): Document[] {
  return Object.values(documents).filter(doc => doc.category === category)
}

// Helper function to search documents
export function searchDocuments(query: string): Document[] {
  const lowerQuery = query.toLowerCase()
  return Object.values(documents).filter(doc => 
    doc.title.toLowerCase().includes(lowerQuery) ||
    doc.description.toLowerCase().includes(lowerQuery)
  )
}
