import React from 'react';
import { ShoppingCart, Repeat } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface Product {
  id: string;
  title: string;
  price: number;
  image: string;
  canSwap: boolean;
  category: string;
}

interface ProductCardProps {
  product: Product;
  onClick: (product: Product) => void;
}

export const ProductCard: React.FC<ProductCardProps> = ({ product, onClick }) => {
  return (
    <div 
      onClick={() => onClick(product)}
      className="group relative bg-[#161618] rounded-[20px] overflow-hidden cursor-pointer transition-all duration-300 hover:bg-[#1C1C1E]"
    >
      <div className="aspect-[1/1] relative overflow-hidden">
        <ImageWithFallback
          src={product.image}
          alt={product.title}
          className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
        />
        {product.canSwap && (
          <div className="absolute top-3 left-3 flex items-center justify-center w-7 h-7 rounded-full bg-black/40 backdrop-blur-md border border-white/10">
            <Repeat size={12} className="text-blue-400" />
          </div>
        )}
      </div>
      
      <div className="p-3">
        <div className="flex justify-between items-center gap-2">
          <div className="min-w-0">
            <h3 className="text-[13px] font-medium text-white/80 line-clamp-1">
              {product.title}
            </h3>
            <span className="text-[14px] font-semibold text-white">
              ${product.price.toLocaleString()}
            </span>
          </div>
          <button 
            onClick={(e) => {
              e.stopPropagation();
            }}
            className="w-8 h-8 flex items-center justify-center rounded-full bg-white/5 hover:bg-white/10 transition-colors"
          >
            <ShoppingCart size={14} className="text-white/60" />
          </button>
        </div>
      </div>
    </div>
  );
};
