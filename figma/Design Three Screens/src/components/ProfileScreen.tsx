import React from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Settings, ShieldCheck, Star, Grid, LayoutGrid, Sun, Moon } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { useTheme } from './ThemeProvider';

interface StoreItem {
  id: string;
  title: string;
  price: number;
  image: string;
  isSold?: boolean;
}

const MOCK_FOR_SALE: StoreItem[] = [
  { id: 'fs1', title: 'Vintage Lens', price: 450, image: 'https://images.unsplash.com/photo-1755136983366-b958dcd2053e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsZWljYSUyMGNhbWVyYSUyMG1pbmltYWxpc3R8ZW58MXx8fHwxNzY5NzY5MTAxfDA&ixlib=rb-4.1.0&q=80&w=1080' },
  { id: 'fs2', title: 'Smart Watch', price: 299, image: 'https://images.unsplash.com/photo-1594120665604-953402382256?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsdXh1cnklMjB3YXRjaCUyMG1pbmltYWxpc3QlMjBkYXJrfGVufDF8fHx8MTc2OTc2OTEwMXww&ixlib=rb-4.1.0&q=80&w=1080' },
  { id: 'fs3', title: 'Mechanical Keyboard', price: 150, image: 'https://images.unsplash.com/photo-1763750581767-b367bcd6c117?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjBzbmVha2VycyUyMG1pbmltYWxpc3QlMjBkYXJrfGVufDF8fHx8MTc2OTc2OTEwMXww&ixlib=rb-4.1.0&q=80&w=1080' },
  { id: 'fs4', title: 'Matte Lamp', price: 85, image: 'https://images.unsplash.com/photo-1762803733564-fecc7669a91a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkZXNpZ25lciUyMGNoYWlyJTIwbW9kZXJuJTIwZnVybml0dXJlJTIwZGFya3xlbnwxfHx8fDE3Njk3NjkxMDF8MA&ixlib=rb-4.1.0&q=80&w=1080' },
];

const MOCK_SOLD: StoreItem[] = [
  { id: 's1', title: 'Analog Camera', price: 520, image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&q=80&w=600', isSold: true },
  { id: 's2', title: 'Leather Tote', price: 180, image: 'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&q=80&w=600', isSold: true },
  { id: 's3', title: 'Studio Chair', price: 900, image: 'https://images.unsplash.com/photo-1592078615290-033ee584e267?auto=format&fit=crop&q=80&w=600', isSold: true },
];

export const ProfileScreen: React.FC = () => {
  const [activeTab, setActiveTab] = React.useState<'for-sale' | 'sold'>('for-sale');
  const { theme, toggleTheme } = useTheme();

  const items = activeTab === 'for-sale' ? MOCK_FOR_SALE : MOCK_SOLD;

  return (
    <div className="pb-32 pt-4 min-h-screen bg-app-bg transition-colors duration-300">
      {/* Header Section */}
      <div className="px-5">
        <header className="flex justify-between items-start mb-6">
          <div className="flex flex-col gap-4 w-full">
            <div className="flex items-center gap-5">
              <div className="w-20 h-20 rounded-[30px] bg-gradient-to-tr from-blue-500/20 to-violet-500/20 p-[1px]">
                <div className="w-full h-full rounded-[29px] bg-app-bg overflow-hidden p-1">
                  <img src="https://api.dicebear.com/7.x/avataaars/svg?seed=Felix" alt="Felix" className="w-full h-full object-cover" />
                </div>
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-1.5 mb-1">
                  <h1 className="text-xl font-bold text-app-text-primary transition-colors">Felix Anderson</h1>
                  <ShieldCheck size={16} className="text-blue-500" />
                </div>
                <p className="text-app-text-secondary text-[13px] font-medium leading-relaxed max-w-[200px] transition-colors">
                  Curating minimal artifacts and timeless tech. Verified trader since 2024.
                </p>
              </div>
              <div className="flex gap-2">
                <button 
                  onClick={toggleTheme}
                  className="w-10 h-10 bg-app-surface rounded-2xl flex items-center justify-center text-app-text-secondary active:scale-90 transition-all border border-app-border"
                >
                  {theme === 'dark' ? <Moon size={18} /> : <Sun size={18} />}
                </button>
                <button className="w-10 h-10 bg-app-surface rounded-2xl flex items-center justify-center text-app-text-secondary active:scale-90 transition-all border border-app-border">
                  <Settings size={18} />
                </button>
              </div>
            </div>

            {/* Stats Row */}
            <div className="flex justify-between items-center bg-app-surface rounded-3xl p-5 border border-app-border transition-colors">
              <div className="text-center">
                <div className="text-lg font-bold text-app-text-primary transition-colors">12</div>
                <div className="text-[10px] font-bold text-app-text-secondary uppercase tracking-widest mt-0.5 transition-colors">Items</div>
              </div>
              <div className="w-[1px] h-8 bg-app-border transition-colors" />
              <div className="text-center">
                <div className="text-lg font-bold text-app-text-primary transition-colors">48</div>
                <div className="text-[10px] font-bold text-app-text-secondary uppercase tracking-widest mt-0.5 transition-colors">Sold</div>
              </div>
              <div className="w-[1px] h-8 bg-app-border transition-colors" />
              <div className="text-center">
                <div className="flex items-center gap-1">
                  <span className="text-lg font-bold text-app-text-primary transition-colors">4.9</span>
                  <Star size={14} className="text-yellow-500 fill-yellow-500" />
                </div>
                <div className="text-[10px] font-bold text-app-text-secondary uppercase tracking-widest mt-0.5 transition-colors">Rating</div>
              </div>
            </div>
          </div>
        </header>

        {/* Appearance Settings Section */}
        <div className="mb-8 p-5 bg-app-surface rounded-3xl border border-app-border transition-colors">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-sm font-bold text-app-text-primary transition-colors">Appearance</h3>
            <span className="text-[12px] font-semibold text-app-text-secondary uppercase tracking-wider transition-colors">
              {theme === 'dark' ? 'Dark Mode' : 'Light Mode'}
            </span>
          </div>
          <button 
            onClick={toggleTheme}
            className="w-full relative h-12 bg-app-bg rounded-2xl flex items-center p-1 border border-app-border transition-all"
          >
            <motion.div
              className="absolute h-10 w-[calc(50%-4px)] bg-app-surface rounded-xl shadow-lg border border-app-border"
              animate={{ x: theme === 'dark' ? '0%' : '100%' }}
              transition={{ type: 'spring', stiffness: 300, damping: 30 }}
            />
            <div className="relative flex-1 flex items-center justify-center gap-2 text-[13px] font-bold z-10 text-app-text-primary transition-colors">
              <Moon size={14} />
              <span>Dark</span>
            </div>
            <div className="relative flex-1 flex items-center justify-center gap-2 text-[13px] font-bold z-10 text-app-text-primary transition-colors">
              <Sun size={14} />
              <span>Light</span>
            </div>
          </button>
        </div>

        {/* Tab Switcher */}
        <div className="relative mb-6 p-1 bg-app-surface rounded-2xl flex gap-1 border border-app-border transition-colors">
          <motion.div
            layoutId="profile-tab-bg"
            className="absolute inset-y-1 bg-app-bg rounded-xl shadow-sm border border-app-border"
            animate={{
              left: activeTab === 'for-sale' ? '4px' : '50%',
              right: activeTab === 'for-sale' ? '50%' : '4px',
            }}
            transition={{ type: 'spring', bounce: 0.1, duration: 0.4 }}
          />
          <button
            onClick={() => setActiveTab('for-sale')}
            className={`relative flex-1 py-3 text-[13px] font-bold transition-colors z-10 ${
              activeTab === 'for-sale' ? 'text-app-text-primary' : 'text-app-text-secondary'
            }`}
          >
            For Sale
          </button>
          <button
            onClick={() => setActiveTab('sold')}
            className={`relative flex-1 py-3 text-[13px] font-bold transition-colors z-10 ${
              activeTab === 'sold' ? 'text-app-text-primary' : 'text-app-text-secondary'
            }`}
          >
            Sold
          </button>
        </div>
      </div>

      {/* Product Grid */}
      <div className="px-5">
        <div className="grid grid-cols-2 gap-3">
          <AnimatePresence mode="popLayout">
            {items.map((item) => (
              <motion.div
                key={item.id}
                layout
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
                transition={{ duration: 0.2 }}
                className="relative aspect-square rounded-[28px] overflow-hidden bg-app-surface border border-app-border group transition-colors"
              >
                <ImageWithFallback
                  src={item.image}
                  alt={item.title}
                  className={`w-full h-full object-cover transition-transform duration-700 group-hover:scale-110 ${
                    item.isSold ? 'grayscale-[0.4] opacity-80' : ''
                  }`}
                />
                
                {/* Corner Price Badge */}
                <div className="absolute top-3 right-3 px-2.5 py-1.5 bg-black/40 backdrop-blur-xl border border-white/10 rounded-full">
                  <span className="text-[11px] font-bold text-white">${item.price}</span>
                </div>

                {/* Sold Overlay */}
                {item.isSold && (
                  <div className="absolute inset-0 bg-black/40 flex items-center justify-center">
                    <div className="px-4 py-2 border-2 border-white/40 rounded-xl backdrop-blur-sm rotate-[-12deg]">
                      <span className="text-sm font-black text-white uppercase tracking-widest">Sold</span>
                    </div>
                  </div>
                )}

                {/* Info Gradient (Only on For Sale) */}
                {!item.isSold && (
                  <div className="absolute inset-x-0 bottom-0 p-4 bg-gradient-to-t from-black/80 to-transparent pt-10">
                    <p className="text-[13px] font-semibold text-white truncate">{item.title}</p>
                  </div>
                )}
              </motion.div>
            ))}
          </AnimatePresence>
        </div>

        {items.length === 0 && (
          <div className="py-20 text-center">
            <div className="w-16 h-16 bg-app-surface rounded-full flex items-center justify-center mx-auto mb-4 border border-app-border transition-colors">
              <LayoutGrid size={32} className="text-app-text-secondary opacity-30" />
            </div>
            <p className="text-app-text-secondary text-sm font-medium transition-colors">No items found</p>
          </div>
        )}
      </div>
    </div>
  );
};
