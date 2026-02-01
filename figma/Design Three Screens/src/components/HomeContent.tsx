import React from "react";
import { motion, AnimatePresence } from "motion/react";
import {
  Search,
  SlidersHorizontal,
  LayoutGrid,
  List,
  MessageSquare,
} from "lucide-react";
import { ProductCard } from "./ProductCard";
import { ProductFeedCard } from "./ProductFeedCard";

const CATEGORIES = [
  "All",
  "Electronics",
  "Footwear",
  "Lifestyle",
  "Watches",
];

interface HomeProps {
  products: any[];
  onProductClick: (product: any, mode: "explore" | "feed") => void;
  onMessagesClick: () => void;
}

export const HomeContent: React.FC<HomeProps> = ({
  products,
  onProductClick,
  onMessagesClick,
}) => {
  const [selectedCategory, setSelectedCategory] =
    React.useState("All");
  const [viewMode, setViewMode] = React.useState<
    "explore" | "feed"
  >("explore");

  return (
    <div className="pb-24 pt-4 bg-app-bg transition-colors duration-300">
      <header className="px-5 mb-6">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-3xl font-bold tracking-tight text-app-text-primary transition-colors">
            Swap-Shop
          </h1>
          <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-blue-500 to-violet-500 p-[1px]">
            <div className="w-full h-full rounded-full bg-app-bg flex items-center justify-center overflow-hidden transition-colors">
              <img
                src="https://api.dicebear.com/7.x/avataaars/svg?seed=Felix"
                alt="Avatar"
                className="w-full h-full"
              />
            </div>
          </div>
        </div>

        {/* Search Bar & Messages */}
        <div className="flex gap-3 mb-6">
          <div className="flex-1 relative">
            <Search
              className="absolute left-4 top-1/2 -translate-y-1/2 text-app-text-secondary"
              size={18}
            />
            <input
              type="text"
              placeholder="Search products..."
              className="w-full bg-app-surface border-none rounded-2xl py-3.5 pl-11 pr-4 text-app-text-primary placeholder:text-app-text-secondary/50 focus:ring-1 focus:ring-app-text-primary/10 transition-all text-sm"
            />
          </div>
          <button className="w-12 h-12 flex items-center justify-center bg-app-surface rounded-2xl text-app-text-secondary transition-all active:bg-app-text-secondary/10 border border-app-border">
            <SlidersHorizontal size={20} />
          </button>
          <button 
            onClick={onMessagesClick}
            className="w-12 h-12 flex items-center justify-center bg-app-surface rounded-2xl text-app-text-secondary transition-all active:bg-app-text-secondary/10 relative border border-app-border"
          >
            <MessageSquare size={20} />
            <div className="absolute top-3 right-3 w-2.5 h-2.5 bg-blue-500 rounded-full border-2 border-app-bg transition-colors" />
          </button>
        </div>

        {/* Mode Switcher - Elegant Segmented Control */}
        <div className="p-1 bg-app-surface rounded-xl flex relative mb-2 border border-app-border transition-colors">
          <motion.div
            className="absolute top-1 bottom-1 bg-app-bg rounded-[9px] shadow-sm pointer-events-none border border-app-border"
            initial={false}
            animate={{
              left: viewMode === "explore" ? "4px" : "50%",
              right: viewMode === "explore" ? "50%" : "4px",
            }}
            transition={{
              type: "spring",
              stiffness: 300,
              damping: 30,
            }}
          />
          <button
            onClick={() => setViewMode("explore")}
            className={`flex-1 flex items-center justify-center gap-2 py-2 relative z-10 transition-colors duration-200 ${
              viewMode === "explore"
                ? "text-app-text-primary"
                : "text-app-text-secondary"
            }`}
          >
            <LayoutGrid size={16} />
            <span className="text-[12px] font-semibold tracking-wide uppercase">
              Explore
            </span>
          </button>
          <button
            onClick={() => setViewMode("feed")}
            className={`flex-1 flex items-center justify-center gap-2 py-2 relative z-10 transition-colors duration-200 ${
              viewMode === "feed"
                ? "text-app-text-primary"
                : "text-app-text-secondary"
            }`}
          >
            <List size={16} />
            <span className="text-[12px] font-semibold tracking-wide uppercase">
              Feed
            </span>
          </button>
        </div>
      </header>

      {/* Categories */}
      <div className="px-5 mb-8 overflow-x-auto no-scrollbar">
        <div className="flex gap-2.5 whitespace-nowrap">
          {CATEGORIES.map((category) => (
            <button
              key={category}
              onClick={() => setSelectedCategory(category)}
              className={`px-5 py-2 rounded-full text-[13px] font-medium transition-all duration-300 border ${
                selectedCategory === category
                  ? "bg-app-text-primary text-app-bg shadow-lg border-app-text-primary"
                  : "bg-app-surface text-app-text-secondary border-app-border hover:text-app-text-primary"
              }`}
            >
              {category}
            </button>
          ))}
        </div>
      </div>

      {/* Main Content Area */}
      <div className="px-5">
        <AnimatePresence mode="wait">
          {viewMode === "explore" ? (
            <motion.div
              key="explore-grid"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              transition={{ duration: 0.2 }}
              className="grid grid-cols-2 gap-4"
            >
              {products.map((product) => (
                <ProductCard
                  key={product.id}
                  product={product}
                  onClick={(p) => onProductClick(p, "explore")}
                />
              ))}
            </motion.div>
          ) : (
            <motion.div
              key="feed-list"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              transition={{ duration: 0.2 }}
            >
              {products.map((product) => (
                <ProductFeedCard
                  key={product.id}
                  product={product}
                  onClick={(p) => onProductClick(p, "feed")}
                />
              ))}
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
};