import { DatabaseHelper } from '../utils/DatabaseHelper';
import { ErrorHandler } from '../utils/ErrorHandler';
import { DiaryEditParams } from '../types/DiaryTypes';
import router from '@ohos.router';

@Entry
@Component
struct DiaryEditPage {
  @State title: string = '';
  @State content: string = '';
  @State isLoading: boolean = false;
  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();
  private userId: number = 0;
  private mode: string = 'add'; // 'add' 或 'edit'
  private diaryId: number = 0;

  aboutToAppear() {
    const params = router.getParams() as DiaryEditParams;
    this.userId = params?.userId || 0;
    this.mode = params?.mode || 'add';
    
    if (this.mode === 'edit') {
      this.diaryId = params?.diaryId || 0;
      this.title = params?.title || '';
      this.content = params?.content || '';
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
        // 顶部导航栏
        Row() {
          Button('取消')
            .backgroundColor(Color.Transparent)
            .fontColor('#667eea')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              router.back();
            })
          
          Blank()
          
          Text(this.mode === 'add' ? '新建笔记' : '编辑笔记')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2c3e50')
          
          Blank()
          
          Button('保存')
            .backgroundColor(Color.Transparent)
            .fontColor('#667eea')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .enabled(!this.isLoading)
            .onClick(() => {
              this.saveDiary();
            })
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

        // 编辑区域
        Scroll() {
          Column() {
            // 标题输入区域
            Column() {
              Text('标题')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2c3e50')
                .margin({ bottom: 12 })
                .alignSelf(ItemAlign.Start)

              TextInput({ placeholder: '请输入笔记标题', text: this.title })
                .width('100%')
                .height(60)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .backgroundColor('#f8f9fa')
                .borderRadius(12)
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.title = value;
                })
                .textAlign(TextAlign.Start)
                .placeholderColor('#95a5a6')
                .fontColor('#2c3e50')
                .caretColor('#667eea')
                .border({ width: 1, color: '#e9ecef' })
            }
            .margin({ bottom: 24 })

            // 内容输入区域
            Column() {
              Text('内容')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2c3e50')
                .margin({ bottom: 12 })
                .alignSelf(ItemAlign.Start)

              TextArea({ placeholder: '写点什么...', text: this.content })
                .width('100%')
                .height(300)
                .fontSize(16)
                .backgroundColor('#f8f9fa')
                .borderRadius(12)
                .padding(16)
                .placeholderColor('#95a5a6')
                .fontColor('#2c3e50')
                .caretColor('#667eea')
                .onChange((value: string) => {
                  this.content = value;
                })
                .textAlign(TextAlign.Start)
                .border({ width: 1, color: '#e9ecef' })
            }
            .margin({ bottom: 24 })

          }
          .width('100%')
          .padding(20)
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Color.White)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  async saveDiary() {
    if (!this.title.trim()) {
      ErrorHandler.showWarning('请输入日记标题');
      return;
    }

    if (!this.content.trim()) {
      ErrorHandler.showWarning('请输入日记内容');
      return;
    }

    this.isLoading = true;

    try {
      let success = false;
      
      if (this.mode === 'add') {
        // 新建日记
        success = await this.dbHelper.addDiary(this.userId, this.title.trim(), this.content.trim());
        if (success) {
          ErrorHandler.showSuccess('保存成功');
          router.back();
        } else {
          ErrorHandler.handleDatabaseError(null, '保存');
        }
      } else {
        // 编辑日记
        success = await this.dbHelper.updateDiary(this.diaryId, this.title.trim(), this.content.trim());
        if (success) {
          ErrorHandler.showSuccess('更新成功');
          router.back();
        } else {
          ErrorHandler.handleDatabaseError(null, '更新');
        }
      }
    } catch (error) {
      ErrorHandler.handleGeneralError(error as Error, '操作失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }
}
