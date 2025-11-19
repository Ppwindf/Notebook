import { DatabaseHelper } from '../utils/DatabaseHelper';
import { DateUtils } from '../utils/DateUtils';
import { ErrorHandler } from '../utils/ErrorHandler';
import { Diary, DiaryListParams, DiaryEditParams } from '../types/DiaryTypes';
import router from '@ohos.router';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;
  @State userId: number = 0;

  aboutToAppear() {
    // 获取传递的用户ID
    const params = router.getParams() as DiaryListParams;
    this.userId = params?.userId || 0;
  }

  build() {
    Column() {
      // 主内容区域
      Tabs({
        barPosition: BarPosition.End,
        index: this.currentIndex
      }) {
        // 首页 - 日记列表
        TabContent() {
          DiaryListPage({ userId: this.userId })
        }
        .tabBar(this.TabBuilder('首页', 0))

        // 个人页面
        TabContent() {
          ProfilePage({ userId: this.userId })
        }
        .tabBar(this.TabBuilder('个人', 1))
      }
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TabBuilder( title: string, index: number ) {
    Column() {
      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? '#0ea5e9' : '#95a5a6')
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
  }
}

// 日记列表页面组件
@Component
struct DiaryListPage {
  @Prop userId: number = 0;
  @State diaries: Diary[] = [];
  @State isLoading: boolean = true;
  @State searchQuery: string = '';
  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();
  private touchStartTime: number = 0;
  private isLongPress: boolean = false;

  aboutToAppear() {
    this.loadDiaries();
  }

  onPageShow() {
    // 页面显示时重新加载日记列表
    this.loadDiaries();
  }

  async loadDiaries() {
    this.isLoading = true;
    try {
      const list = await this.dbHelper.getDiaries(this.userId);
      // 重新按更新时间排序，确保一致性
      this.diaries = list.sort((a, b) => (a.updated_at < b.updated_at ? 1 : -1));
    } catch (error) {
      ErrorHandler.handleDatabaseError(error as Error, '加载日记');
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#e0f7fa', 0.0], ['#e8f0fe', 1.0]]
        })

      Column() {
        // 顶部区域：搜索 + 刷新
        Column() {
          Row() {
            // 搜索框
            TextInput({ placeholder: '搜索标题或内容', text: this.searchQuery })
              .layoutWeight(1)
              .height(44)
              .backgroundColor('#ffffff')
              .borderRadius(22)
              .padding({ left: 16, right: 16 })
              .fontSize(14)
              .placeholderColor('#94a3b8')
              .border({ width: 1, color: '#e2e8f0' })
              .onChange((value: string) => {
                this.searchQuery = value;
              })

            // 右侧操作区（固定宽度容器）
            Row() {
              // 刷新按钮（小圆）
              Button('刷新')
                .width(70)
                .height(40)
                .backgroundColor('#e0f2fe')
                .borderRadius(22)
                .fontColor('#0ea5e9')
                .fontSize(18)
                .enabled(!this.isLoading)
                .onClick(() => {
                  this.loadDiaries();
                })
                .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })

            }
            .height(44)
            .margin({ left: 12 })
            .alignItems(VerticalAlign.Center)
          }
          .height(44)
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 16 })
        .backgroundColor('#ff578f92')
        .borderRadius({ bottomLeft: 20, bottomRight: 20 })
        .shadow({ radius: 12, color: '#00000010', offsetX: 0, offsetY: 4 })

        // 日记列表
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(60)
              .height(60)
              .color('#0ea5e9')
            Text('加载中...')
              .fontSize(16)
              .fontColor('#7f8c8d')
              .margin({ top: 16 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.diaries.length === 0) {
          Column() {
            Stack() {
              Circle()
                .width(120)
                .height(120)
                .fill('#0ea5e920')

              Image($r('app.media.background'))
                .width(60)
                .height(60)
                .borderRadius(30)
                .backgroundColor('#0ea5e9')
            }
            .margin({ bottom: 24 })

            Text('还没有日记')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2c3e50')
              .margin({ bottom: 8 })

            Text('点击右上角新建按钮开始写日记')
              .fontSize(14)
              .fontColor('#7f8c8d')
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .padding(40)
        } else {
          // 改为两列卡片网格布局
          Grid() {
            ForEach(this.getFilteredDiaries(), (diary: Diary, index: number) => {
              GridItem() {
                this.DiaryCard(diary, index)
              }
            })
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          .width('100%')
          .height('100%')
        }
      }
      .width('100%')
      .height('100%')

      // 新建按钮
      Button('+')
        .width(58)
        .height(58)
        .margin({ left: 12 })
        .backgroundColor('#0ea5e9')
        .borderRadius(22)
        .fontColor(Color.White)
        .fontSize(18)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/DiaryEditPage',
            params: { userId: this.userId, mode: 'add' } as DiaryEditParams
          })
        })
        .position({ bottom: 30 , right: 30 })

    }
    .width('100%')
    .height('100%')
  }

  // 搜索过滤（标题或内容包含关键字）
  getFilteredDiaries(): Diary[] {
    const q = this.searchQuery.trim().toLowerCase();
    if (!q) return this.diaries;
    const filtered = [] as Diary[];
    for (let i = 0; i < this.diaries.length; i++) {
      const d = this.diaries[i];
      const t = (d.title || '').toLowerCase();
      const c = (d.content || '').toLowerCase();
      if (t.indexOf(q) >= 0 || c.indexOf(q) >= 0) {
        filtered.push(d);
      }
    }
    return filtered;
  }

  @Builder
  DiaryCard(diary: Diary, index: number) {
    Column() {
      // 顶部标题与操作
      Row() {
        Text(diary.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#0f172a')
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(DateUtils.formatDate(diary.updated_at))
          .fontSize(10)
          .fontColor('#64748b')
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 内容摘要
      Text(diary.content)
        .fontSize(13)
        .fontColor('#334155')
        .maxLines(4)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      // 底部操作区
      Row() {
        Button('编辑')
          .height(34)
          .padding({ left: 12, right: 12 })
          .backgroundColor('#e0f2fe')
          .borderRadius(8)
          .fontColor('#0ea5e9')
          .fontSize(12)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/DiaryEditPage',
              params: {
                userId: this.userId,
                mode: 'edit',
                diaryId: diary.id,
                title: diary.title,
                content: diary.content
              } as DiaryEditParams
            });
          })

        Blank()

        Button('删除')
          .height(34)
          .padding({ left: 12, right: 12 })
          .backgroundColor('#fee2e2')
          .borderRadius(8)
          .fontColor('#ef4444')
          .fontSize(12)
          .onClick(() => {
            this.showDeleteConfirm(diary);
          })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .padding(14)
    .backgroundColor('#ffffff')
    .borderRadius(14)
    .shadow({ radius: 10, color: '#00000010', offsetX: 0, offsetY: 6 })
  }

  showDeleteConfirm(diary: Diary) {
    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除日记"${diary.title}"吗？此操作不可撤销。`,
      primaryButton: {
        value: '取消',
        action: () => {
          // 取消操作
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#e74c3c',
        action: () => {
          this.deleteDiary(diary.id);
        }
      }
    });
  }

  async deleteDiary(diaryId: number) {
    try {
      const success = await this.dbHelper.deleteDiary(diaryId);
      if (success) {
        ErrorHandler.showSuccess('删除成功');
        this.loadDiaries(); // 重新加载列表
      } else {
        ErrorHandler.handleDatabaseError(null, '删除');
      }
    } catch (error) {
      ErrorHandler.handleDatabaseError(error as Error, '删除');
    }
  }
}

// 个人页面组件
@Component
struct ProfilePage {
  @Prop userId: number = 0;
  @State username: string = '';
  @State pageOpacity: number = 0;
  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();

  aboutToAppear() {
    this.loadUserInfo();
    this.startAnimation();
  }

  startAnimation() {
    setTimeout(() => {
      animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
        this.pageOpacity = 1;
      });
    }, 200);
  }

  async loadUserInfo() {
    try {
      const user = await this.dbHelper.getUserById(this.userId);
      if (user) {
        this.username = user.username;
      } else {
        this.username = `用户${this.userId}`;
      }
    } catch (error) {
      ErrorHandler.handleDatabaseError(error as Error, '加载用户信息');
    }
  }

  build() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#f8f9fa', 0.0], ['#e9ecef', 1.0]]
        })

      Column() {
        // 顶部标题
        Row() {
          Text('个人中心')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2c3e50')
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 20 })
        .backgroundColor(Color.White)
        .shadow({
          radius: 8,
          color: '#00000010',
          offsetX: 0,
          offsetY: 2
        })

        // 用户信息卡片
        Column() {
          Row() {
            Stack() {
              Circle()
                .width(80)
                .height(80)
                .fill('#667eea20')
              
              Text(this.username.charAt(0).toUpperCase())
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor('#667eea')
            }
            .margin({ left: 20, right: 20 })

            Column() {
              Text(this.username)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2c3e50')
                .margin({ bottom: 4 })
              
              Text('记事本用户')
                .fontSize(14)
                .fontColor('#7f8c8d')
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(20)
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ top: 20, left: 20, right: 20 })
        .shadow({
          radius: 6,
          color: '#00000008',
          offsetX: 0,
          offsetY: 2
        })

        // 功能列表
        Column() {
          // 账号信息
          Blank()
            .width('100%').height(30)

          this.MenuItem('账号信息', () => {
            this.showAccountInfo();
          })

          Blank()
            .width('100%').height(30)

          // 修改密码
          this.MenuItem('修改密码', () => {
            this.showChangePassword();
          })

          Blank()
            .width('100%').height(30)

          // 退出登录
          this.MenuItem('退出登录', () => {
            this.showLogoutConfirm();
          }, true)

          Blank()
            .width('100%').height(30)

        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ top: 20, left: 20, right: 20 })
        .shadow({
          radius: 6,
          color: '#00000008',
          offsetX: 0,
          offsetY: 2
        })
      }
      .width('100%')
      .height('100%')
      .padding({ top: 20 })
      .opacity(this.pageOpacity)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MenuItem(title: string, onClick: () => void, isDestructive: boolean = false) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(isDestructive ? '#e74c3c' : '#2c3e50')
        .layoutWeight(1)


      Text('>')
        .fontSize(24)
        .fontColor(Color.White)
    }
    .width('80%')
    .backgroundColor('#99a2a19b')
    .border(({radius: 10, color: Color.Transparent}))
    .borderRadius(10)
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .onClick(onClick)
  }

  showAccountInfo() {
    AlertDialog.show({
      title: '账号信息',
      message: `用户名：${this.username}\n用户ID：${this.userId}`,
      primaryButton: {
        value: '确定',
        action: () => {
          // 关闭对话框
        }
      }
    });
  }

  showChangePassword() {
    // 跳转到修改密码页面
    try {
      router.pushUrl({
        url: 'pages/ChangePasswordPage',
        params: { userId: this.userId } as DiaryEditParams
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      console.error('跳转修改密码页面失败: ', message);
    }
  }


  showLogoutConfirm() {
    AlertDialog.show({
      title: '确认退出',
      message: '确定要退出登录吗？',
      primaryButton: {
        value: '取消',
        action: () => {
          // 取消操作
        }
      },
      secondaryButton: {
        value: '退出',
        fontColor: '#e74c3c',
        action: () => {
          this.logout();
        }
      }
    });
  }

  logout() {
    // 返回登录页面
    try {
      router.replaceUrl({ url: 'pages/LoginPage' });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      console.error('返回登录页面失败: ', message);
    }
  }
}
