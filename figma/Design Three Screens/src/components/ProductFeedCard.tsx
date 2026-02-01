import React from 'react';
import { ShoppingCart, Repeat, ShieldCheck, Heart, Send, MessageSquare } from 'lucide-react';
import { motion, useScroll, useSpring } from 'motion/react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface Product {
  id: string;
  title: string;
  price: number;
  image: string;
  images?: string[];
  canSwap: boolean;
  category: string;
  seller?: {
    name: string;
    avatar: string;
    verified: boolean;
  };
  description?: string;
  timestamp?: string;
}

interface ProductFeedCardProps {
  product: Product;
  onClick: (product: Product) => void;
}

export const ProductFeedCard: React.FC<ProductFeedCardProps> = ({ product, onClick }) => {
  const isCurrentUser = product.seller?.name === 'Felix Anderson';
  const timePosted = product.timestamp || '1 day ago';
  const displayImages = product.images || [product.image];
  
  const [activeIndex, setActiveIndex] = React.useState(0);
  const scrollRef = React.useRef<HTMLDivElement>(null);

  const handleScroll = (e: React.UIEvent<HTMLDivElement>) => {
    const scrollLeft = e.currentTarget.scrollLeft;
    const width = e.currentTarget.offsetWidth;
    if (width > 0) {
      const index = Math.round(scrollLeft / width);
      if (index !== activeIndex) {
        setActiveIndex(index);
      }
    }
  };

  return (
    <div 
      className="bg-app-surface rounded-[32px] overflow-hidden mb-8 border border-app-border transition-colors duration-300"
    >
      {/* Social Header */}
      <div className="px-5 py-5 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-11 h-11 rounded-full bg-app-bg overflow-hidden border border-app-border transition-colors">
            <img 
              src={product.seller?.avatar || `https://api.dicebear.com/7.x/avataaars/svg?seed=${product.id}`} 
              alt="Seller" 
              className="w-full h-full object-cover"
            />
          </div>
          <div className="flex flex-col">
            <div className="flex items-center gap-1.5">
              <span className="text-[15px] font-bold text-app-text-primary leading-none transition-colors">{product.seller?.name || 'Seller'}</span>
              {product.seller?.verified && <ShieldCheck size={14} className="text-blue-500" />}
            </div>
            <span className="text-[12px] text-app-text-secondary font-medium mt-0.5 transition-colors">{timePosted}</span>
          </div>
        </div>
        
        {/* Right Action Icons */}
        <div className="flex items-center gap-4 text-app-text-secondary">
          <button className="active:scale-90 transition-transform">
            <Send size={20} />
          </button>
          <button className="active:scale-90 transition-transform">
            <MessageSquare size={20} />
          </button>
          <button className="active:scale-90 transition-transform hover:text-red-500 transition-colors">
            <Heart size={20} />
          </button>
        </div>
      </div>

      {/* Content Section */}
      <div className="px-5 pb-4">
        <h3 className="text-[18px] font-bold text-app-text-primary mb-2 leading-tight transition-colors">{product.title}</h3>
        <p className="text-[14px] text-app-text-secondary leading-relaxed line-clamp-2 transition-colors">
          {product.description || "A pristine example of design excellence. This piece is part of a curated collection."}
        </p>
      </div>

      {/* Swipeable Media Gallery (Custom Scroll Snap Implementation) */}
      <div className="px-5 pb-10 relative">
        <div 
          ref={scrollRef}
          onScroll={handleScroll}
          className="flex overflow-x-auto snap-x snap-mandatory no-scrollbar rounded-[28px] bg-black/20 aspect-[1.8/1] relative border border-app-border transition-colors"
        >
          {displayImages.map((img, idx) => (
            <div key={idx} className="shrink-0 w-full h-full snap-center">
              <div className="aspect-[1.8/1] w-full h-full">
                <ImageWithFallback
                  src={img}
                  alt={`${product.title} - ${idx + 1}`}
                  className="w-full h-full object-cover"
                />
              </div>
            </div>
          ))}
          
          {/* Price Badge Overlay */}
          <div className="absolute top-4 right-4 px-3 py-1.5 rounded-full bg-black/60 backdrop-blur-xl border border-white/10 z-10 pointer-events-none">
             <span className="text-[13px] font-bold text-white">${product.price.toLocaleString()}</span>
          </div>
        </div>

        {/* Custom Pagination Dots */}
        <div className="absolute bottom-4 left-0 right-0 flex justify-center gap-1.5 pointer-events-none">
          {displayImages.map((_, i) => (
            <div 
              key={i}
              className={`h-1.5 rounded-full transition-all duration-300 ${
                i === activeIndex ? 'bg-app-text-primary w-4' : 'bg-app-text-secondary/20 w-1.5'
              }`}
            />
          ))}
        </div>
      </div>

      {/* Action Bar */}
      <div className="px-5 pb-6 flex gap-3">
        {product.canSwap && !isCurrentUser ? (
          <>
            <button 
              onClick={(e) => { e.stopPropagation(); onClick(product); }}
              className="flex-1 bg-app-bg hover:bg-app-surface text-app-text-primary font-bold py-3.5 rounded-2xl flex items-center justify-center gap-2 transition-all active:scale-95 border border-app-border shadow-sm"
            >
              <Repeat size={18} className="text-blue-400" />
              <span className="text-[14px]">Exchange</span>
            </button>
            <button 
              onClick={(e) => { e.stopPropagation(); onClick(product); }}
              className="flex-1 bg-app-text-primary hover:opacity-90 text-app-bg font-bold py-3.5 rounded-2xl flex items-center justify-center gap-2 transition-all active:scale-95 shadow-lg"
            >
              <ShoppingCart size={18} />
              <span className="text-[14px]">Add to Cart</span>
            </button>
          </>
        ) : (
          <button 
            onClick={(e) => { e.stopPropagation(); onClick(product); }}
            className="w-full bg-app-text-primary hover:opacity-90 text-app-bg font-bold py-3.5 rounded-2xl flex items-center justify-center gap-2 transition-all active:scale-95 shadow-lg"
          >
            <ShoppingCart size={18} />
            <span className="text-[14px]">Add to Cart</span>
          </button>
        )}
      </div>
    </div>
  );
};

