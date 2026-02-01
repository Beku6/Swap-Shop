import React from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Home, Wallet, ShoppingCart, User, Plus } from 'lucide-react';
import { HomeContent } from './components/HomeContent';
import { ProductDetails } from './components/ProductDetails';
import { WalletScreen } from './components/WalletScreen';
import { CartScreen } from './components/CartScreen';
import { SellScreen } from './components/SellScreen';
import { ProfileScreen } from './components/ProfileScreen';
import { MessagesScreen } from './components/MessagesScreen';
import { ThemeProvider, useTheme } from './components/ThemeProvider';

const MOCK_PRODUCTS = [
  {
    id: '1',
    title: 'iPhone 15 Pro Titanium',
    price: 999,
    image: 'https://images.unsplash.com/photo-1698314439902-70a5966b8cc4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxpcGhvbmUlMjAxNSUyMHBybyUyMHRpdGFuaXVtJTIwZGFyayUyMGJhY2tncm91bmR8ZW58MXx8fHwxNzY5NzY5MTAxfDA&ixlib=rb-4.1.0&q=80&w=1080',
    images: [
      'https://images.unsplash.com/photo-1698314439902-70a5966b8cc4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxpcGhvbmUlMjAxNSUyMHBybyUyMHRpdGFuaXVtJTIwZGFyayUyMGJhY2tncm91bmR8ZW58MXx8fHwxNzY5NzY5MTAxfDA&ixlib=rb-4.1.0&q=80&w=1080',
      'https://images.unsplash.com/photo-1769594362058-d561f024a235?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjBlbGVjdHJvbmljJTIwcHJvZHVjdCUyMGRhcmslMjBiYWNrZ3JvdW5kfGVufDF8fHx8MTc2OTg1OTk3N3ww&ixlib=rb-4.1.0&q=80&w=1080'
    ],
    canSwap: true,
    category: 'Electronics',
    description: 'The natural titanium finish is breathtaking. Barely used, includes original box and accessories. Looking for a swap with a high-end lens or cash.',
    seller: { name: 'Sarah J.', avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah', verified: true },
    timestamp: '1 day ago'
  },
  {
    id: '2',
    title: 'Minimalist Dark Sneakers',
    price: 180,
    image: 'https://images.unsplash.com/photo-1763750581767-b367bcd6c117?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjBzbmVha2VycyUyMG1pbmltYWxpc3QlMjBkYXJrfGVufDF8fHx8MTc2OTc2OTEwMXww&ixlib=rb-4.1.0&q=80&w=1080',
    images: [
      'https://images.unsplash.com/photo-1763750581767-b367bcd6c117?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjBzbmVha2VycyUyMG1pbmltYWxpc3QlMjBkYXJrfGVufDF8fHx8MTc2OTc2OTEwMXww&ixlib=rb-4.1.0&q=80&w=1080',
      'https://images.unsplash.com/photo-1611615107443-0e37489ea4da?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjBzbmVha2VyJTIwZGFyayUyMGJhY2tncm91bmR8ZW58MXx8fHwxNzY5ODU5OTc3fDA&ixlib=rb-4.1.0&q=80&w=1080'
    ],
    canSwap: false,
    category: 'Footwear',
    description: 'Limited edition matte black finish. Brand new in box. Size 10. Perfect for an understated architectural look.',
    seller: { name: 'Marcus W.', avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Marcus', verified: true },
    timestamp: '3 hours ago'
  },
  {
    id: '3',
    title: 'Leica Q3 Camera',
    price: 5995,
    image: 'https://images.unsplash.com/photo-1755136983366-b958dcd2053e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsZWljYSUyMGNhbWVyYSUyMG1pbmltYWxpc3R8ZW58MXx8fHwxNzY5NzY5MTAxfDA&ixlib=rb-4.1.0&q=80&w=1080',
    images: [
      'https://images.unsplash.com/photo-1755136983366-b958dcd2053e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsZWljYSUyMGNhbWVyYSUyMG1pbmltYWxpc3R8ZW58MXx8fHwxNzY5NzY5MTAxfDA&ixlib=rb-4.1.0&q=80&w=1080',
      'https://images.unsplash.com/photo-1769594362058-d561f024a235?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtaW5pbWFsaXN0JTIwZWxlY3Ryb25pYyUyMHByb2R1Y3QlMjBkYXJrJTIwYmFja2dyb3VuZHxlbnwxfHx8fDE3Njk4NTk5Nzd8MA&ixlib=rb-4.1.0&q=80&w=1080'
    ],
    canSwap: true,
    category: 'Lifestyle',
    description: 'A masterpiece of optical engineering. Shutter count under 500. Interested in bartering for high-end furniture or rare watches.',
    seller: { name: 'Elena R.', avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Elena', verified: true },
    timestamp: 'Just now'
  },
  {
    id: '4',
    title: 'Modern Designer Chair',
    price: 450,
    image: 'https://images.unsplash.com/photo-1762803733564-fecc7669a91a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkZXNpZ25lciUyMGNoYWlyJTIwbW9kZXJuJTIwZnVybml0dXJlJTIwZGFya3xlbnwxfHx8fDE3Njk3NjkxMDF8MA&ixlib=rb-4.1.0&q=80&w=1080',
    images: [
      'https://images.unsplash.com/photo-1762803733564-fecc7669a91a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkZXNpZ25lciUyMGNoYWlyJTIwbW9kZXJuJTIwZnVybml0dXJlJTIwZGFya3xlbnwxfHx8fDE3Njk3NjkxMDF8MA&ixlib=rb-4.1.0&q=80&w=1080',
      'https://images.unsplash.com/photo-1769255119622-1bd8e49ff35c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtaW5pbWFsaXN0JTIwZnVybml0dXJlJTIwY2hhaXIlMjBkYXJrJTIwYmFja2dyb3VuZHxlbnwxfHx8fDE3Njk4NTk5Nzd8MA&ixlib=rb-4.1.0&q=80&w=1080'
    ],
    canSwap: true,
    category: 'Electronics',
    description: 'Ergonomic excellence meets sculptural beauty. Slight patina on the leather which only adds to its character.',
    seller: { name: 'Julian B.', avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Julian', verified: false },
    timestamp: '2 days ago'
  },
  {
    id: '5',
    title: 'Luxury Graphite Watch',
    price: 12500,
    image: 'https://images.unsplash.com/photo-1594120665604-953402382256?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsdXh1cnklMjB3YXRjaCUyMG1pbmltYWxpc3QlMjBkYXJrfGVufDF8fHx8MTc2OTc2OTEwMXww&ixlib=rb-4.1.0&q=80&w=1080',
    images: [
      'https://images.unsplash.com/photo-1594120665604-953402382256?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsdXh1cnklMjB3YXRjaCUyMG1pbmltYWxpc3QlMjBkYXJrfGVufDF8fHx8MTc2OTc2OTEwMXww&ixlib=rb-4.1.0&q=80&w=1080',
      'https://images.unsplash.com/photo-1769594362058-d561f024a235?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtaW5pbWFsaXN0JTIwZWxlY3Ryb25pYyUyMHByb2R1Y3QlMjBkYXJrJTIwYmFja2dyb3VuZHxlbnwxfHx8fDE3Njk4NTk5Nzd8MA&ixlib=rb-4.1.0&q=80&w=1080'
    ],
    canSwap: true,
    category: 'Watches',
    description: 'Automatic movement with 72-hour power reserve. This watch is a statement of precision. Full set with papers.',
    seller: { name: 'Sophia L.', avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sophia', verified: true },
    timestamp: '4 days ago'
  }
];

export default function App() {
  return (
    <ThemeProvider>
      <AppContent />
    </ThemeProvider>
  );
}

function AppContent() {
  const [activeTab, setActiveTab] = React.useState('home');
  const [selectedProduct, setSelectedProduct] = React.useState<any>(null);
  const [sourceMode, setSourceMode] = React.useState<'explore' | 'feed'>('explore');
  const [showMessages, setShowMessages] = React.useState(false);

  const handleProductClick = (product: any, mode: 'explore' | 'feed') => {
    setSourceMode(mode);
    setSelectedProduct(product);
  };

  const renderContent = () => {
    switch (activeTab) {
      case 'home':
        return <HomeContent 
          products={MOCK_PRODUCTS} 
          onProductClick={handleProductClick} 
          onMessagesClick={() => setShowMessages(true)} 
        />;
      case 'cart':
        return <CartScreen />;
      case 'sell':
        return <SellScreen />;
      case 'wallet':
        return <WalletScreen />;
      case 'profile':
        return <ProfileScreen />;
      default:
        return <HomeContent products={MOCK_PRODUCTS} onProductClick={handleProductClick} onMessagesClick={() => setShowMessages(true)} />;
    }
  };

  return (
    <div className="min-h-screen bg-app-bg text-app-text-primary font-sans selection:bg-blue-500/30 overflow-x-hidden transition-colors duration-300 pb-24">
      {/* Dynamic Content Area */}
      <div className="max-w-lg mx-auto">
        <AnimatePresence mode="wait">
          <motion.div
            key={activeTab}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            transition={{ duration: 0.25, ease: [0.32, 0.72, 0, 1] }}
          >
            {renderContent()}
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Messages Overlay */}
      <AnimatePresence>
        {showMessages && (
          <motion.div
            initial={{ x: '100%' }}
            animate={{ x: 0 }}
            exit={{ x: '100%' }}
            transition={{ type: 'spring', damping: 30, stiffness: 200 }}
            className="fixed inset-0 z-50 bg-app-bg"
          >
            <MessagesScreen onBack={() => setShowMessages(false)} />
          </motion.div>
        )}
      </AnimatePresence>

      {/* Product Details Modal */}
      <AnimatePresence>
        {selectedProduct && (
          <motion.div
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={{ type: 'spring', damping: 30, stiffness: 200 }}
            className="fixed inset-0 z-50"
          >
            <ProductDetails 
              product={selectedProduct} 
              sourceMode={sourceMode}
              onBack={() => setSelectedProduct(null)} 
            />
          </motion.div>
        )}
      </AnimatePresence>

      {/* Bottom Navigation */}
      {!selectedProduct && (
        <nav className="fixed bottom-0 left-0 right-0 bg-app-nav-bg backdrop-blur-3xl border-t border-app-border z-40 transition-colors duration-300">
          <div className="max-w-lg mx-auto px-6 py-4 flex justify-between items-end">
            <NavButton 
              active={activeTab === 'home'} 
              onClick={() => setActiveTab('home')} 
              icon={Home} 
              label="Home"
            />
            <NavButton 
              active={activeTab === 'cart'} 
              onClick={() => setActiveTab('cart')} 
              icon={ShoppingCart} 
              label="Cart"
            />
            
            {/* Center Elevated Sell Button */}
            <div className="flex flex-col items-center gap-1.5 -mb-2">
               <button 
                  onClick={() => setActiveTab('sell')}
                  className={`w-14 h-14 rounded-full flex items-center justify-center shadow-2xl transition-all duration-300 active:scale-90 ${
                    activeTab === 'sell' 
                      ? 'bg-app-text-primary text-app-bg shadow-app-text-primary/10' 
                      : 'bg-app-surface text-app-text-secondary border border-app-border'
                  }`}
               >
                 <Plus size={30} strokeWidth={2.5} />
               </button>
               <span className={`text-[10px] font-bold uppercase tracking-widest transition-colors ${
                 activeTab === 'sell' ? 'text-app-text-primary' : 'text-app-text-secondary'
               }`}>Sell</span>
            </div>

            <NavButton 
              active={activeTab === 'wallet'} 
              onClick={() => setActiveTab('wallet')} 
              icon={Wallet} 
              label="Wallet"
            />
            <NavButton 
              active={activeTab === 'profile'} 
              onClick={() => setActiveTab('profile')} 
              icon={User} 
              label="Me"
            />
          </div>
          <div className="h-6" /> {/* Safe area */}
        </nav>
      )}
    </div>
  );
}

const NavButton = ({ active, onClick, icon: Icon, label }: any) => (
  <button 
    onClick={onClick}
    className={`flex flex-col items-center gap-1.5 transition-all duration-300 w-12 ${
      active ? 'text-app-nav-active' : 'text-app-nav-inactive hover:text-app-text-secondary'
    }`}
  >
    <div className="relative">
      <Icon size={22} strokeWidth={active ? 2.5 : 2} />
      {active && (
        <motion.div 
          layoutId="nav-dot"
          className="absolute -bottom-2 left-1/2 -translate-x-1/2 w-1 h-1 bg-app-nav-active rounded-full"
        />
      )}
    </div>
    <span className="text-[10px] font-bold uppercase tracking-widest">{label}</span>
  </button>
);
