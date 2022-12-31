#include <iostream>
#include <sstream>

#include "common/exception.h"
#include "storage/page/b_plus_tree_internal_page.h"
/*
 *内部结点实现说明：
 *    本文件主要实现内部结点的初始化、查找、分裂，合并以及重分配等
 *  算法。因为内部结点的变动（分裂，合并以及重分配）会产生迭代，
 *  因此在这些算法中，要特别注意this结点的父节点的设置。
 *  
 *  
 *  
 */

namespace bustub {
/*
 * 函数功能：
 *  初始化this页，包括page type,size,page id,parent id and max page size
 *  输入：
 *    page_id_t page_id 页号
 *    page_id_t parent_id 父页号
 *    int max_size 页元素最大值
 *  提示：因为是内部页类，因此页类型应该设置为IndexPageType::INTERNAL_PAGE
 */
INDEX_TEMPLATE_ARGUMENTS
void B_PLUS_TREE_INTERNAL_PAGE_TYPE::Init(page_id_t page_id, page_id_t parent_id, int max_size) {
  SetPageId(page_id);
  SetParentPageId(parent_id);
  SetMaxSize(max_size);
  SetPageType(IndexPageType::INTERNAL_PAGE);
  SetSize(0);
}

/*
 * 函数功能：
 *  返回index处的key值
 * 建议：
 *   1.leaf页数组中元素为pair，first为key，second为RID
 *   2.internal页数组中元素为pair，first为key，second为PAGE_ID
 */
INDEX_TEMPLATE_ARGUMENTS
KeyType B_PLUS_TREE_INTERNAL_PAGE_TYPE::KeyAt(int index) const {
  return array_[index].first;
}
/*
 * 函数功能：
 *  设置index处的key值
 * 建议：
 *   
 *   1.internal数组中元素为pair，first为key，second为PAGE_ID
 */

INDEX_TEMPLATE_ARGUMENTS
void B_PLUS_TREE_INTERNAL_PAGE_TYPE::SetKeyAt(int index, const KeyType &key) { 
	array_[index].first = key;
}

/*
 * 函数功能：
 *  寻找当前结点所有的键值（key）对中值为value的元素的索引
 * 建议：
 *  1.如果未找到，返回-1
 */
INDEX_TEMPLATE_ARGUMENTS
int B_PLUS_TREE_INTERNAL_PAGE_TYPE::ValueIndex(const ValueType &value) const {
  for (int i = 0; i < GetSize(); i++) {
    if (array_[i].second == value) {
      return i;
    }
  }
  return -1;
}
/*
 * 函数功能：
 *  返回索引index处的value
 *
 */
INDEX_TEMPLATE_ARGUMENTS
ValueType B_PLUS_TREE_INTERNAL_PAGE_TYPE::ValueAt(int index) const {
  return array_[index].second;
}

/*****************************************************************************
 * 查找
 *****************************************************************************/
/*
 * 函数功能：
 *  在key值有序排列的数组中，找到特定key值对应的value
 * 建议：
 *  1.选择合适查找法
 *  2.如果key值不存在，返回最接近的较小key对应的value
 *  3.使用comparator进行key值的比较
 */
INDEX_TEMPLATE_ARGUMENTS
ValueType B_PLUS_TREE_INTERNAL_PAGE_TYPE::Lookup(const KeyType &key, const KeyComparator &comparator) const {
  assert(GetSize() > 1);
  int i = 0, j = GetSize() - 1, m, res;
  while (i <= j) {
    m = (i + j) / 2;
    res = comparator(array_[m].first, key);
    if (!res) {
      return array_[m].second;
    } else if (res < 0) {
      i = m + 1;
    } else {
      j = m - 1;
    }
  }
  return array_[j].second;
}

/*****************************************************************************
 * 内部结点分裂
 *****************************************************************************/
/* 使用场景
 *  当根结点中元素过多时，会在分裂后原来的根节点会变为内部结点，同时要创建新的根节点
 *  对新创建的根节点需要初始化
 * 函数功能：
 *  对新的根结点进行初始化填充
 * 建议：
 *  1.该函数仅在InsertIntoParent()(b_plus_tree.cpp)中调用
 *  2.初始化后根结点中元素为[<invalid, old_value>, <new_key, new_value>]
 *  3.当节点分裂时，分裂的new_Key需要通过函数InsertIntoParent()插入到父节点中，
 *    如果当前节点为根节点，那么需要创建新的根节点，并通过PopulateNewRoot函数初始化它
 *  4.更新size=2
 */
INDEX_TEMPLATE_ARGUMENTS
void B_PLUS_TREE_INTERNAL_PAGE_TYPE::PopulateNewRoot(const ValueType &old_value, const KeyType &new_key,
                                                     const ValueType &new_value) {
  //该函数为由于底层变动生成新的根元素，此时对该根元素进行设置
  array_[0].second = old_value;
  array_[1].first = new_key;
  array_[1].second = new_value;
  SetSize(2);
}
/* 使用场景：
 *  B+树的插入：当B+树结点分裂，会创造一个新的split结点，通过调用InsertIntoParent函数
 *  将新的split结点插入到父节点，在InsertIntoParent函数中需要调用InsertNodeAfter进行
 *  插入。
 * 函数功能：
 *  在当前page中找到old_value的位置，然后将new_key和new_value插入其中
 * 建议：
 *  1.键值对溢出的情况以及父子关系此处无需处理，后续可以在外部处理
 *  2.如果old_value不存在，返回-1
 *  3.return size 
 * 处理逻辑建议：
 *  1.通过old_value找到old_value所在的索引位置old_index
 *  2.如果old_index=-1,函数返回-1
 *  3.如果old_index<>-1，那么将old_index之后的元素(不含old_index)向后移动一位
 *  4.在old_index将新的键值对插入进来
 */
INDEX_TEMPLATE_ARGUMENTS
int B_PLUS_TREE_INTERNAL_PAGE_TYPE::InsertNodeAfter(const ValueType &old_value, const KeyType &new_key,
                                                    const ValueType &new_value) {
  //当底层元素分裂后，需要在父节点的当前底层元素索引（old_value）后添加新节点指向分裂后的新底层节点
  int old_index = ValueIndex(old_value);
  if (old_index == -1) {
    return -1;
  } else {
    for (int i = GetSize() - 1; i > old_index; i--) {
      array_[i + 1] = array_[i];
    }
    array_[old_index + 1].first = new_key;
    array_[old_index + 1].second = new_value;
    SetSize(GetSize() + 1);
    return GetSize();
  }
}

/*****************************************************************************
 * 内部结点分裂
 *****************************************************************************/
/*
 *函数功能：
 * 移动this结点中一半（向上取整）的元素到一个新生成的recipient结点中
 *建议：
 *  1.优先实现CopyNFrom函数
 *  2.在内部调用CopyNFrom函数实现该功能
 *  3.一般用于当前结点中元素溢出时进行分裂，将多余元素移入新结点中。（请在函数外部进行父结点元素的更新）
 *  eg:
 *    this == r1,  recipient == r2
 *    r1->[<invalid, p0>, <1, p1>, <2, p2>, <3, p3>, <4, p4>] ----MoveHalfTo--> r2[]
 *    result: r1->[<invalid, p0>, <1, p1>],r2[<2, p2>, <3, p3>, <4, p4>]
 */
INDEX_TEMPLATE_ARGUMENTS
void B_PLUS_TREE_INTERNAL_PAGE_TYPE::MoveHalfTo(BPlusTreeInternalPage *recipient,
                                                BufferPoolManager *buffer_pool_manager) {
  int half = GetSize() / 2;
  recipient->CopyNFrom(array_ + half, GetSize() - half, buffer_pool_manager);
  SetSize(half);
}

/*
 * 函数功能：
 *  从item处开始，截取size个键值对并入到结点的尾部
 * 建议：
 *  1.由于该结点属于内部结点，结点中元素迁移后需要对子元素的ParentPageId进行更新，即对子结点进行fetch，更新后再unpin
 *  2.更新size
 */
INDEX_TEMPLATE_ARGUMENTS
void B_PLUS_TREE_INTERNAL_PAGE_TYPE::CopyNFrom(MappingType *items, int size, BufferPoolManager *buffer_pool_manager) {
	//内部节点的索引指向了子元素结点，当迁移后这个关系仍不变
	//但是由于内部节点一部分迁移到了新的结点，故这部分的子元素结点的父元素需要调整
	//故需要把page从磁盘中取出，即bufferpool
  //例程：
  //将array_[i].second(Page_id)所对应的页取出来，并赋给指针page
  //Page *page = buffer_pool_manager->FetchPage(array_[i].second);
  // page->GetData()强转为BPlusTreePage
  //  BPlusTreePage *bp_tree_page = reinterpret_cast<BPlusTreePage *>(page->GetData());
  // bp_tree_page的父结点设置为本节点
  // bp_tree_page->SetParentPageId(GetPageId());
  // 更新完毕后再unpin
  // buffer_pool_manager->UnpinPage(array_[i].second, true);
  int size_ = GetSize();
  for (int i = size_; i < size_ + size; i++) {
    array_[i] = *items++;
    Page *page = buffer_pool_manager->FetchPage(array_[i].second);
    BPlusTreePage *bp_tree_page = reinterpret_cast<BPlusTreePage *>(page->GetData());
    bp_tree_page->SetParentPageId(GetPageId());
    buffer_pool_manager->UnpinPage(array_[i].second, true);
    IncreaseSize(1);
  }
}

/*****************************************************************************
 * 内部结点移除
 *****************************************************************************/
/*
 * 函数功能：
 *  1.移除this结点中的index处的键值对
 * 建议：
 *  1.注意元素的移动
 *  2.更新size
 */
INDEX_TEMPLATE_ARGUMENTS
void B_PLUS_TREE_INTERNAL_PAGE_TYPE::Remove(int index) {
  for (int i = index; i < GetSize() - 1; i++) {
    array_[i] = array_[i + 1];
  }
  IncreaseSize(-1);
}

/* 使用情景：
 *  当根节点只有一个子节点时，可以将这个根节点删除，并将其子节点提升起来作为根节点
 * 函数功能：
 *  返回根结点含有的唯一元素ValueAt(0)
 * 建议：
 *  1.该函数只在AdjustRoot()(in b_plus_tree.cpp)中调用
 *  2.更新size
 */ 
INDEX_TEMPLATE_ARGUMENTS
ValueType B_PLUS_TREE_INTERNAL_PAGE_TYPE::RemoveAndReturnOnlyChild() { 
  IncreaseSize(-1);
  return ValueAt(0);
}
/*****************************************************************************
 * 内部结点合并
 *****************************************************************************/
/*使用场景：
 *  当前节点删除 key 后，节点的数量小于 MinSize, 如果 sibling size 很少的情况下，
 *  不宜进行重分配，否则兄弟节点的 size 将小于MinSize，此时应考虑合并。当兄弟节点的 
 *  size 没有到达最大值时，当前节点的剩余键值对可以合并入该节点。
 *函数功能：
 *  合并this结点的元素至recipient结点中，即将this结点中的全部元素移至recipient结点的尾部
 *建议：
 *  1.this结点的变化影响了其子结点（子结点的父结点属性需要进行更新）
 *  2.更新recipient结点的size大小
 *  3.this结点的变化影响了其父结点（父结点中指向该结点的键值对需要被清除）,此操作在函数外进行，
 *    不需要在此处实现
 */
INDEX_TEMPLATE_ARGUMENTS
void B_PLUS_TREE_INTERNAL_PAGE_TYPE::MoveAllTo(BPlusTreeInternalPage *recipient,
                                               BufferPoolManager *buffer_pool_manager) {
  int start = recipient->GetSize();
  page_id_t recipientPageId = recipient->GetPageId();
  // the separation key from parent
	//the separation key的value指向该结点，即该结点上元素的值均大于该value
	//该结点的首元素无key值，无法直接合并到recipient，首元素所指向的值比the separation key大比一号元素小（即首元素的key实际上就是the separation key）
  Page* page = buffer_pool_manager->FetchPage(GetParentPageId());
  assert(page != nullptr);
  BPlusTreeInternalPage* parent = reinterpret_cast<BPlusTreeInternalPage*>(page->GetData());
  int idx = parent->ValueIndex(GetPageId());
  SetKeyAt(0,parent->KeyAt(idx));
  buffer_pool_manager->UnpinPage(parent->GetPageId(), false);
  for (int i = 0; i < GetSize(); i++)
  {
    recipient->array_[start + i].first = array_[i].first;
    recipient->array_[start + i].second = array_[i].second;
    auto childRawPage = buffer_pool_manager->FetchPage(array_[i].second);
    BPlusTreePage* child = reinterpret_cast<BPlusTreePage*>(childRawPage->GetData());
    child->SetParentPageId(recipientPageId);
    buffer_pool_manager->UnpinPage(array_[i].second, true);
  }
  recipient->SetSize(start + GetSize());
  assert(recipient->GetSize() <= GetMaxSize());
  SetSize(0);
}

/*****************************************************************************
 * 重分配
 *****************************************************************************/
/*使用场景：
 *  当前节点删除 key 后，节点的数量小于 MinSize,而如果 sibling size 很满的情况下，
 *  不宜进行merge，否则兄弟节 点的 size 将溢出，此时应考虑重分配。将满的sibling结点
 *  的首元素移到本节点，进行重分配。
 *
 * 函数功能：
 *  移动this结点的首元素至recipient结点的末尾
 * 建议：
 *  1.recipient调用CopyLastFrom函数实现节点更新
 *  2.this结点更新size
 *  3.由于this结点首元素变化，因此父结点中this结点的索引需要更新
 */
INDEX_TEMPLATE_ARGUMENTS
void B_PLUS_TREE_INTERNAL_PAGE_TYPE::MoveFirstToEndOf(BPlusTreeInternalPage *recipient,
                                                      BufferPoolManager *buffer_pool_manager) {
  Page *page = buffer_pool_manager->FetchPage(GetParentPageId());
  assert(page != nullptr);
  BPlusTreeInternalPage* parent = reinterpret_cast<BPlusTreeInternalPage*>(page->GetData());
  int index = parent->ValueIndex(GetPageId());
  SetKeyAt(0, parent->KeyAt(index));
  MappingType pair{KeyAt(0), ValueAt(0)};
  IncreaseSize(-1);
	//数组空间整体向前移动一个单位
  memmove(array_, array_ + 1, static_cast<size_t>(GetSize() * sizeof(MappingType)));
  recipient->CopyLastFrom(pair, buffer_pool_manager);
	//当移动头元素后，有以下结点需要调整
	//该结点由于头元素发生了变化（即无效元素改变），此时父结点指向该结点的元素key值需要调整，为新的无效元素的key值上移至该元素
  // update relavent key & value pair in its parent page.
  parent->SetKeyAt(parent->ValueIndex(GetPageId()), array_[0].first);
  buffer_pool_manager->UnpinPage(GetParentPageId(), true);
}

/*
 * 函数功能：
 *  将pair元素添加到this结点的尾部
 * 建议：
 *  1.更新pair元素的父结点信息为this结点的PageId
 *  2.更新size
 */
INDEX_TEMPLATE_ARGUMENTS
void B_PLUS_TREE_INTERNAL_PAGE_TYPE::CopyLastFrom(const MappingType &pair, BufferPoolManager *buffer_pool_manager) {
  array_[GetSize()] = pair;
  IncreaseSize(1);
  Page* page = buffer_pool_manager->FetchPage(pair.second);
  assert(page != nullptr);
  BPlusTreePage* child = reinterpret_cast<BPlusTreePage*>(page->GetData());
  child->SetParentPageId(GetPageId());
  buffer_pool_manager->UnpinPage(child->GetPageId(), true);
}
/*
 * 函数功能：
 *  移动this结点的尾部元素至recipient结点的头部
 * 建议：
 *  1.recipient调用CopyFirstFrom函数实现节点更新
 *  2.this结点更新size
 */
INDEX_TEMPLATE_ARGUMENTS
void B_PLUS_TREE_INTERNAL_PAGE_TYPE::MoveLastToFrontOf(BPlusTreeInternalPage *recipient,
                                                       BufferPoolManager *buffer_pool_manager) {
  MappingType pair{KeyAt(GetSize() - 1), ValueAt(GetSize() - 1)};
  SetSize(GetSize() - 1);
  recipient->CopyFirstFrom(pair, buffer_pool_manager);
}
/*
 * 函数功能：
 *  移动pair元素至recipient结点的首部
 * 建议：
 *  1.由于首元素变化，需要对父结点中的索引进行更新
 *  2.更新size
 *  3.更新pair元素的父结点信息
 */
INDEX_TEMPLATE_ARGUMENTS
void B_PLUS_TREE_INTERNAL_PAGE_TYPE::CopyFirstFrom(const MappingType &pair, BufferPoolManager *buffer_pool_manager) {
  Page* page = buffer_pool_manager->FetchPage(GetParentPageId());
  assert(page != nullptr);
  BPlusTreeInternalPage* parent = reinterpret_cast<BPlusTreeInternalPage*>(page->GetData());
  int idx = parent->ValueIndex(GetPageId());
  SetKeyAt(0, parent->KeyAt(idx));
  memmove(array_ + 1, array_, GetSize() * sizeof(MappingType));
  array_[0].first = pair.first;
  array_[0].second = pair.second;
  SetSize(GetSize() + 1);
  page = buffer_pool_manager->FetchPage(pair.second);
  assert(page != nullptr);
  BPlusTreePage* child = reinterpret_cast<BPlusTreePage*>(page->GetData());
  child->SetParentPageId(GetPageId());
  buffer_pool_manager->UnpinPage(child->GetPageId(), true);
  parent->SetKeyAt(parent->ValueIndex(GetPageId()), array_[0].first);
  buffer_pool_manager->UnpinPage(GetParentPageId(), true);
}

template class BPlusTreeInternalPage<GenericKey<4>, page_id_t, GenericComparator<4>>;
template class BPlusTreeInternalPage<GenericKey<8>, page_id_t, GenericComparator<8>>;
template class BPlusTreeInternalPage<GenericKey<16>, page_id_t, GenericComparator<16>>;
template class BPlusTreeInternalPage<GenericKey<32>, page_id_t, GenericComparator<32>>;
template class BPlusTreeInternalPage<GenericKey<64>, page_id_t, GenericComparator<64>>;
}
