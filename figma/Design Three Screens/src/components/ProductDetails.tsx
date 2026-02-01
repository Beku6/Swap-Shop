import React from 'react';
import { motion } from 'motion/react';
import { ChevronLeft, ShoppingCart, Repeat, ShieldCheck, Star, ArrowRight, Info } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface ProductDetailsProps {
  product: any;
  onBack: () => void;
  sourceMode: 'explore' | 'feed';
}

export const ProductDetails: React.FC<ProductDetailsProps> = ({ product, onBack, sourceMode }) => {
  const isFeedSource = sourceMode === 'feed';

  return (
    <div className="fixed inset-0 bg-app-bg z-50 overflow-y-auto no-scrollbar transition-colors duration-300">
      {/* Header Overlay */}
      <div className="fixed top-0 left-0 right-0 p-6 z-10 flex justify-between items-center pointer-events-none">
        <button 
          onClick={onBack}
          className="pointer-events-auto w-10 h-10 flex items-center justify-center bg-black/40 backdrop-blur-xl rounded-full border border-white/10 text-white transition-transform active:scale-95"
        >
          <ChevronLeft size={20} />
        </button>
      </div>

      {/* Hero Image */}
      <div className="relative w-full aspect-[3/4] sm:aspect-[4/5]">
        <ImageWithFallback
          src={product.image}
          alt={product.title}
          className="w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-app-bg via-transparent to-transparent opacity-80 transition-colors duration-300" />
      </div>

      {/* Content Container */}
      <div className="relative px-6 -mt-20 pb-40 max-w-lg mx-auto">
        {/* Category & Rating */}
        <div className="flex justify-between items-center mb-3">
          <span className="text-[11px] font-bold tracking-[0.2em] text-blue-500 uppercase">
            {product.category}
          </span>
          <div className="flex items-center gap-1 text-app-text-secondary">
            <Star size={12} className="text-amber-400 fill-amber-400" />
            <span className="text-[12px] font-medium">4.9 (124)</span>
          </div>
        </div>

        <h1 className="text-3xl font-bold text-app-text-primary mb-6 leading-tight tracking-tight transition-colors">
          {product.title}
        </h1>

        {/* Dual Purchase Options - Equal Weight */}
        <div className="grid grid-cols-2 gap-4 mb-8">
          {/* Option 1: Market Purchase */}
          <div className="bg-app-surface p-5 rounded-[24px] border border-app-border relative overflow-hidden group transition-colors">
            <div className="absolute top-0 right-0 p-3 opacity-10 group-hover:opacity-20 transition-opacity">
               <ShoppingCart size={40} />
            </div>
            <div className="text-[11px] font-bold text-app-text-secondary uppercase tracking-wider mb-2">Market Price</div>
            <div className="text-2xl font-bold text-app-text-primary mb-1 transition-colors">${product.price.toLocaleString()}</div>
            <div className="text-[10px] text-app-text-secondary opacity-60">Instant checkout available</div>
          </div>

          {/* Option 2: Barter Exchange */}
          <div className="bg-app-surface p-5 rounded-[24px] border border-app-border relative overflow-hidden group transition-colors">
             <div className="absolute top-0 right-0 p-3 opacity-10 group-hover:opacity-20 transition-opacity">
               <Repeat size={40} className="text-blue-400" />
            </div>
            <div className="text-[11px] font-bold text-blue-400 uppercase tracking-wider mb-2">Barter Exchange</div>
            <div className="text-2xl font-bold text-app-text-primary mb-1 transition-colors">Trade</div>
            <div className="text-[10px] text-app-text-secondary opacity-60">Item-for-item swap enabled</div>
          </div>
        </div>

        {/* Trust & Safety Indicator */}
        <div className="flex items-center gap-3 px-4 py-3 bg-blue-500/5 border border-blue-500/10 rounded-2xl mb-8">
          <ShieldCheck size={18} className="text-blue-400 shrink-0" />
          <p className="text-[12px] text-blue-200/60 leading-tight">
            Protected by <span className="text-blue-400 font-semibold">Swap Escrow</span>. Funds and items are held securely until both parties confirm delivery.
          </p>
        </div>

        {/* Seller Info */}
        <div className="bg-app-surface p-5 rounded-[24px] border border-app-border mb-8 transition-colors">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-full bg-app-bg overflow-hidden ring-2 ring-app-border transition-all">
                <img 
                  src={product.seller?.avatar || `https://api.dicebear.com/7.x/avataaars/svg?seed=${product.id}`} 
                  alt="Seller" 
                  className="w-full h-full object-cover"
                />
              </div>
              <div>
                <div className="flex items-center gap-1.5 text-app-text-primary font-semibold transition-colors">
                  {product.seller?.name || 'Seller'}
                  {product.seller?.verified && <ShieldCheck size={14} className="text-blue-500" />}
                </div>
                <div className="text-[11px] text-app-text-secondary transition-colors">Member since 2023 • 98% Trust Score</div>
              </div>
            </div>
            <button className="text-[12px] font-bold text-blue-400 flex items-center gap-1">
              Profile <ArrowRight size={14} />
            </button>
          </div>
          
          {/* Adaptive Content: More seller context if from Feed */}
          {isFeedSource && (
            <motion.div 
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              className="pt-4 border-t border-app-border grid grid-cols-2 gap-4"
            >
              <div className="text-center p-2 rounded-xl bg-app-bg border border-app-border">
                <div className="text-app-text-primary font-bold text-sm">48</div>
                <div className="text-[9px] uppercase text-app-text-secondary tracking-widest">Successful Swaps</div>
              </div>
              <div className="text-center p-2 rounded-xl bg-app-bg border border-app-border">
                <div className="text-app-text-primary font-bold text-sm">&lt; 2h</div>
                <div className="text-[9px] uppercase text-app-text-secondary tracking-widest">Avg. Response</div>
              </div>
            </motion.div>
          )}
        </div>

        {/* Description Section */}
        <div className="space-y-4">
          <div className="flex items-center gap-2">
            <h3 className="text-app-text-primary font-bold uppercase tracking-wider text-[11px] opacity-90 transition-colors">Details</h3>
            <div className="h-[1px] flex-1 bg-app-border" />
          </div>
          <p className="text-app-text-secondary text-[15px] leading-relaxed transition-colors">
            {product.description || "A pristine example of design excellence. This piece is part of a curated collection, maintained with extreme care and ready for its next home."}
          </p>
          
          {/* Detailed Specs - only show more if from Feed or manually requested */}
          {isFeedSource && (
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="grid grid-cols-2 gap-x-8 gap-y-3 pt-2"
            >
              {[
                { label: 'Condition', value: 'Like New' },
                { label: 'Authenticity', value: 'Verified' },
                { label: 'Original Box', value: 'Yes' },
                { label: 'Shipping', value: 'Global' },
              ].map((spec, i) => (
                <div key={i} className="flex justify-between border-b border-app-border pb-2">
                  <span className="text-[12px] text-app-text-secondary">{spec.label}</span>
                  <span className="text-[12px] text-app-text-primary font-medium">{spec.value}</span>
                </div>
              ))}
            </motion.div>
          )}
        </div>
      </div>

      {/* Fixed Action Bar */}
      <div className="fixed bottom-0 left-0 right-0 p-6 bg-gradient-to-t from-app-bg via-app-bg to-transparent pt-10 z-20 transition-all duration-300">
        <div className="max-w-lg mx-auto flex gap-4">
          <button className="flex-1 flex items-center justify-center gap-2 bg-app-surface border border-app-border text-app-text-primary font-bold py-4 rounded-[20px] transition-all active:scale-95 hover:bg-app-surface/80">
            <Repeat size={18} className="text-blue-400" />
            <span>Propose Swap</span>
          </button>
          <button className="flex-1 flex items-center justify-center gap-2 bg-app-text-primary text-app-bg font-bold py-4 rounded-[20px] transition-all active:scale-95 hover:opacity-90 shadow-lg">
            <ShoppingCart size={18} />
            <span>Add to Cart</span>
          </button>
        </div>
        <div className="h-4" /> {/* Safe area spacer */}
      </div>
    </div>
  );
};
